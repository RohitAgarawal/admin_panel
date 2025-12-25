import 'package:admin_panel/network_connection/apis.dart';
import 'package:admin_panel/provider/support_chat_provider/support_chat_provider.dart';
import 'package:admin_panel/support_chat/support_chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class SupportChatListScreen extends StatefulWidget {
  const SupportChatListScreen({super.key});

  @override
  State<SupportChatListScreen> createState() => _SupportChatListScreenState();
}

class _SupportChatListScreenState extends State<SupportChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch chats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupportChatProvider>(context, listen: false).getAllChats();
      Provider.of<SupportChatProvider>(
        context,
        listen: false,
      ).listenToSocket(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Support Chats"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<SupportChatProvider>(
                context,
                listen: false,
              ).getAllChats();
            },
          ),
        ],
      ),
      body: Consumer<SupportChatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingChats) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.allChats.isEmpty) {
            return Center(child: Text("No support chats yet"));
          }

          return ListView.builder(
            itemCount: provider.allChats.length,
            itemBuilder: (context, index) {
              final chat = provider.allChats[index];
              final user = chat['userId']; // Populated user object
              final lastMessage = chat['lastMessage']; // Populated or ID?
              // If populated, lastMessage is object.

              String userName = "Unknown User";
              if (user != null) {
                final fName = user['fName'] ?? "";
                final mName = user['mName'] ?? "";
                final lName = user['lName'] ?? "";
                final fullName = "$fName $mName $lName".trim();

                if (fullName.isNotEmpty) {
                  userName = fullName;
                } else {
                  userName = user['email'] ?? "Unknown User";
                }
              }
              final String lastMsgContent = lastMessage != null
                  ? (lastMessage['type'] == 'image'
                        ? 'Image'
                        : lastMessage['content'] ?? "")
                  : "No messages";

              // Date
              String time = "";
              if (chat['updatedAt'] != null) {
                time = timeago.format(DateTime.parse(chat['updatedAt']));
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      (user != null &&
                          user['profileImage'] != null &&
                          user['profileImage'].isNotEmpty)
                      ? NetworkImage(Apis.BASE_URL_IMAGE + user['profileImage'])
                      : null,
                  child:
                      (user == null ||
                          user['profileImage'] == null ||
                          user['profileImage'].isEmpty)
                      ? Text(userName.substring(0, 1).toUpperCase())
                      : null,
                ),
                title: Text(userName),
                subtitle: Text(
                  lastMsgContent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  // Navigate to chat detail
                  // Need to check if user['userId'] or chat['_id'] used for fetching
                  // getMessages(userId) uses USER ID based on our backend controller.
                  // So we pass user['_id'].
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SupportChatDetailScreen(
                          userId: user['_id'],
                          userName: userName,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
