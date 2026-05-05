import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/profile_page.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/services/chat/chat_services.dart';

class ChatScreen extends StatefulWidget {
  final String receiverName;
  final String receiverAvatarUrl;
  final String userId;
  final Map<String, dynamic>? receiverData;

  const ChatScreen({
    super.key,
    required this.receiverName,
    required this.receiverAvatarUrl,
    required this.userId,
    this.receiverData,
  });

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

  Future<void> _openReceiverProfile() async {
    final userData =
        widget.receiverData ?? await auth.getUserData(widget.userId);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProfilePage(userId: widget.userId, userData: userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: _openReceiverProfile,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                _buildReceiverAvatar(radius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.receiverName,
                        style: TextStyle(
                          color: colorScheme.inversePrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "View profile",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildChatMessagesList()),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: .65),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _scrollToBottom();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "Write a message",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filled(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded, size: 19),
                    ),
                  ],
                ),
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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyConversation();
        } else {
          final messages = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 18),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(
          mainAxisAlignment: isCurrentUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) ...[
              _buildReceiverAvatar(radius: 16),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.tertiary,
                  border: isCurrentUser
                      ? null
                      : Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: .65),
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                    bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                  ),
                ),
                child: Text(
                  (message['text'] ?? '').toString(),
                  style: TextStyle(
                    color: isCurrentUser
                        ? Colors.white
                        : Theme.of(context).colorScheme.inversePrimary,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyConversation() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReceiverAvatar(radius: 36),
            const SizedBox(height: 14),
            Text(
              "Start a chat with ${widget.receiverName}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.inversePrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Say hi or tap the top bar to view their profile.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiverAvatar({required double radius}) {
    if (widget.receiverAvatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        backgroundImage: NetworkImage(widget.receiverAvatarUrl),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: Text(
        widget.receiverName.isNotEmpty
            ? widget.receiverName[0].toUpperCase()
            : '?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
          fontSize: radius,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
