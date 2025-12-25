import 'package:admin_panel/network_connection/apis.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketProvider extends ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;

  IO.Socket? get socket => _socket;
  bool get isConnected => _isConnected;

  void connectToSocket() {
    if (_isConnected) return;

    try {
      _socket = IO.io(Apis.SOCKET_URL, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      _socket?.connect();

      _socket?.onConnect((_) {
        print('Socket Connected: ${_socket?.id}');
        _isConnected = true;
        notifyListeners();
      });

      _socket?.onDisconnect((_) {
        print('Socket Disconnected');
        _isConnected = false;
        notifyListeners();
      });

      _socket?.onError((data) {
        print('Socket Error: $data');
      });
    } catch (e) {
      print('Socket connection error: $e');
    }
  }

  void joinAdminSupportRoom() {
    if (_socket != null && _isConnected) {
      _socket?.emit('joinAdminSupport');
      print('Joined Admin Support Room');
    }
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }
}
