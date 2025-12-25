import 'package:admin_panel/provider/support_chat_provider/support_chat_provider.dart';
import 'package:admin_panel/support_chat/support_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupportChatDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const SupportChatDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<SupportChatDetailScreen> createState() =>
      _SupportChatDetailScreenState();
}

class _SupportChatDetailScreenState extends State<SupportChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;
  int _unreadCount = 0;
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SupportChatProvider>(context, listen: false);
      provider.setActiveChat(widget.userId);
      provider.joinAdminRoom(context); // Ensure joined
    });
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      final bool isAtBottom = position.pixels >= position.maxScrollExtent - 100;

      if (isAtBottom && _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = false;
          _unreadCount = 0;
        });
      } else if (!isAtBottom && !_showScrollToBottom) {
        setState(() {
          _showScrollToBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    Provider.of<SupportChatProvider>(context, listen: false).clearActiveChat();
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        setState(() {
          _unreadCount = 0;
          _showScrollToBottom = false;
        });
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final content = _controller.text.trim();
    _controller.clear();

    Provider.of<SupportChatProvider>(
      context,
      listen: false,
    ).sendAdminMessage(widget.userId, content);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.userName)),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Consumer<SupportChatProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoadingMessages) {
                      return Center(child: CircularProgressIndicator());
                    }

                    // Check for new messages
                    if (provider.currentChatMessages.length >
                        _previousMessageCount) {
                      final int newMessages =
                          provider.currentChatMessages.length -
                          _previousMessageCount;
                      _previousMessageCount =
                          provider.currentChatMessages.length;

                      final lastMsg = provider.currentChatMessages.last;
                      String role = lastMsg['senderRole'] ?? '';
                      bool isMe = role == 'admin';

                      if (isMe) {
                        _scrollToBottom();
                      } else {
                        if (_showScrollToBottom) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _unreadCount += newMessages;
                              });
                            }
                          });
                        } else {
                          _scrollToBottom();
                        }
                      }
                    } else if (provider.currentChatMessages.length <
                        _previousMessageCount) {
                      _previousMessageCount =
                          provider.currentChatMessages.length;
                    }

                    if (_previousMessageCount == 0 &&
                        provider.currentChatMessages.isNotEmpty) {
                      _previousMessageCount =
                          provider.currentChatMessages.length;
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom(),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      itemCount: provider.currentChatMessages.length,
                      itemBuilder: (context, index) {
                        final msg = provider.currentChatMessages[index];
                        return SupportMessageBubble(message: msg);
                      },
                    );
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
          if (_showScrollToBottom && _unreadCount > 0)
            Positioned(
              bottom: 80,
              right: 16,
              child: GestureDetector(
                onTap: _scrollToBottom,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        "$_unreadCount New",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_downward, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            )
          else if (_showScrollToBottom)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _scrollToBottom,
                child: Icon(Icons.keyboard_arrow_down, color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
