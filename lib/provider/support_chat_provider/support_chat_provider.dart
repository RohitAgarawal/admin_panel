import 'dart:convert';
import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:admin_panel/network_connection/apis.dart';
import 'package:admin_panel/provider/socket_provider/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SupportChatProvider extends ChangeNotifier {
  List<dynamic> _allChats = [];
  List<dynamic> _currentChatMessages = [];
  bool _isLoadingChats = false;
  bool _isLoadingMessages = false;
  String? _currentChatId;

  List<dynamic> get allChats => _allChats;
  List<dynamic> get currentChatMessages => _currentChatMessages;
  bool get isLoadingChats => _isLoadingChats;
  bool get isLoadingMessages => _isLoadingMessages;

  Future<void> getAllChats() async {
    _isLoadingChats = true;
    notifyListeners();

    final url = Uri.parse('${Apis.BASE_URL}/support/get-all-chats');
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _allChats = data['data'] ?? [];
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      }
    } catch (e) {
      print("Error fetching all chats: $e");
    } finally {
      _isLoadingChats = false;
      notifyListeners();
    }
  }

  Future<void> getMessages(String userId) async {
    _isLoadingMessages = true;
    notifyListeners();

    final url = Uri.parse('${Apis.BASE_URL}/support/get-messages/$userId');
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentChatMessages = data['data'] ?? [];
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      }
    } catch (e) {
      print("Error fetching messages: $e");
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> sendAdminMessage(String userId, String content) async {
    if (content.trim().isEmpty) return;

    final url = Uri.parse('${Apis.BASE_URL}/support/send-message');
    // Admin sends message. userId represents the RECEIVER (User).
    // Wait, backend `sendMessage` expects `userId` to be the USER who owns the chat?
    // Yes: `let chat = await SupportChatModel.findOne({ userId });`
    // So passing `userId` of the User is correct.

    final body = {
      'userId': userId,
      'senderRole': 'admin',
      'content': content,
      'type': 'text',
    };

    try {
      String token = await AdminSharedPreferences().getAuthToken();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Optimistically add or wait for socket?
        // Socket handles it.
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print("Send failed: ${response.body}");
      }
    } catch (e) {
      print("Error sending admin message: $e");
    }
  }

  // Socket Listener
  void listenToSocket(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.connectToSocket();

    // Allow time to connect then join room (or handle in onConnect in provider)
    // socketProvider.joinAdminSupportRoom(); -> call this separately or ensure connected.

    socketProvider.socket?.on("support_message", (data) {
      print("Admin received support message: $data");
      _handleNewMessage(data);
    });
  }

  void joinAdminRoom(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.joinAdminSupportRoom();
  }

  void _handleNewMessage(dynamic message) {
    if (message == null) return;

    // 1. Update List (Last Message)
    final chatId = message['chatId'];
    final index = _allChats.indexWhere((c) => c['_id'] == chatId);
    if (index != -1) {
      _allChats[index]['lastMessage'] = message;
      // Move to top
      final chat = _allChats.removeAt(index);
      _allChats.insert(0, chat);
      notifyListeners();
    } else {
      // New chat? Fetch all chats again to be safe
      getAllChats();
    }

    // 2. Update Active Chat Detail Screen
    // The backend emits { ...message, userId: user_of_chat }
    // If we are currently viewing this user's chat, append the message.
    if (_activeChatUserId != null && message['userId'] == _activeChatUserId) {
      _currentChatMessages.add(message);
      notifyListeners();
    }
  }

  String? _activeChatUserId;
  void setActiveChat(String userId) {
    _activeChatUserId = userId;
    getMessages(userId);
  }

  void clearActiveChat() {
    _activeChatUserId = null;
    _currentChatMessages = [];
    notifyListeners();
  }
}
