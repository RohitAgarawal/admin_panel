import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:admin_panel/network_connection/apis.dart';

class SupportMessageBubble extends StatelessWidget {
  final dynamic message;

  const SupportMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Admin Side:
    // Me = 'admin' -> Right Side
    // Other = 'user' -> Left Side

    final bool isMe = message['senderRole'] == 'admin';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 1.0,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: isMe ? Radius.circular(12) : Radius.zero,
                bottomRight: isMe ? Radius.zero : Radius.circular(12),
              ),
              color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
              child: Padding(
                padding: EdgeInsets.all(message['type'] == "text" ? 12.0 : 4.0),
                child: _buildMessageContent(context),
              ),
            ),
            SizedBox(height: 4),
            Text(
              timeago.format(
                DateTime.parse(message['createdAt']).toLocal(),
                locale: 'en',
              ),
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    if (message['type'] == 'text') {
      return Text(message['content'] ?? "");
    } else if (message['type'] == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: "${Apis.BASE_URL_IMAGE}${message['content']}",
          width: 150,
          height: 150,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, e) => Icon(Icons.error),
        ),
      );
    }
    return Text("Unsupported type");
  }
}
