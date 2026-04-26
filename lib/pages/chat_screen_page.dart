import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/services/chat/chat_services.dart';

class ChatScreen extends StatefulWidget {
  final String userEmail;
  final String userId;

  const ChatScreen({super.key, required this.userEmail, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final chatServices = ChatServices();

  final auth = AuthService();

  final TextEditingController _messageController = TextEditingController();
  

  final ScrollController _scrollController = ScrollController();
  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      chatServices.sendMessage(message, widget.userId);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.userEmail,
          style: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildChatMessagesList()),

            Text(
              "Chat with ${widget.userEmail}",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onTap: () {
                        Future.delayed(Duration(milliseconds: 300), () {
                          _scrollToBottom();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Type your message",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                    ),
                    child: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessagesList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatServices.getMessagesStream(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No messages yet"));
        } else {
          final messages = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
          return ListView.builder(
            reverse: true,
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isCurrentUser =
                  message['senderEmail'] ==
                  chatServices.getCurrentUser()?.email;
              return _buildChatMessagesListItem(
                message,
                isCurrentUser,
                context,
              );
            },
          );
        }
      },
    );
  }

  Widget _buildChatMessagesListItem(
    Map<String, dynamic> message,
    bool isCurrentUser,
    BuildContext context,
  ) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message['text'],
          style: isCurrentUser
              ? TextStyle(color: Colors.white)
              : TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
