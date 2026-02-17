import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final UserModel otherUser;
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatProvider.stopListeningToMessages();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      await _chatProvider.loadMessages(widget.conversationId);
      print('✓ Messages loaded: ${_chatProvider.messages.length}');
      
      await _chatProvider.markMessagesAsRead(widget.conversationId);
      print('✓ Messages marked as read');
      
      await Future.delayed(Duration(milliseconds: 500)); // Wait for DB update
      
      await _chatProvider.loadConversations();
      print('✓ Conversations reloaded, unread: ${_chatProvider.conversations.where((c) => c.unreadCount > 0).length}');
      
      _chatProvider.listenToMessages(widget.conversationId);
      _scrollToButton();
    } catch (e) {
      print('✗ Error loading messages: $e');
    }
  }

  void _scrollToButton() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessages() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final message = _messageController.text.trim();
    _messageController.clear();

    final success = await chatProvider.sendMessage(
      widget.conversationId,
      message,
    );
    if (success) {
      _scrollToButton();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message')));
    }
  }

  String _formatMessageTimer(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return "${time.day}/${time.month}/${time.year}";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUserId = authProvider.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 18,
              child: widget.otherUser.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        widget.otherUser.avatarUrl!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      widget.otherUser.username[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser.username,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (widget.otherUser.fullName != null &&
                      widget.otherUser.fullName!.isNotEmpty)
                    Text(
                      widget.otherUser.fullName!,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: chatProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : chatProvider.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No Messages yet",
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Start the conversation!",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      final isSentByMe = message.senderId == currentUserId;
                      final showDateSeperator =
                          index == 0 ||
                          !_isSameDay(
                            chatProvider.messages[index - 1].createdAt,
                            message.createdAt,
                          );

                      return Column(
                        children: [
                          if (showDateSeperator)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                _formatDateSeperator(message.createdAt),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ),
                          Align(
                            alignment: isSentByMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isSentByMe
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color: isSentByMe
                                          ? Colors.white
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _formatMessageTimer(message.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSentByMe
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: IconButton(
                    onPressed: _sendMessages,
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDateSeperator(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (_isSameDay(date, now)) {
      return "Today";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}
