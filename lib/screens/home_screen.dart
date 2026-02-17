import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/screens/new_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    await _chatProvider.loadConversations();
    _chatProvider.listenToConversations();
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _chatProvider.stopListeningToConversations();
    await authProvider.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
            icon: Icon(Icons.person),
          ),
          IconButton(onPressed: _logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        child: chatProvider.conversations.isEmpty
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
                      "No conversations yet",
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: chatProvider.conversations.length,
                itemBuilder: (context, index) {
                  final conversation = chatProvider.conversations[index];
                  final otherUser = conversation.otherUser;
                  final lastMessage = conversation.lastMessage;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: otherUser?.avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                otherUser!.avatarUrl!,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              ),
                            )
                          : Text(
                              otherUser?.username[0].toUpperCase() ?? '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    title: Text(
                      otherUser?.username ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: lastMessage != null
                        ? Text(
                            lastMessage.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(),
                          )
                        : Text("No Messages Yet"),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (lastMessage != null)
                          Text(
                            timeago.format(lastMessage.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (conversation.unreadCount > 0)
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            padding: EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            conversationId: conversation.id,
                            otherUser: otherUser!,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewChatScreen()),
          );
        },
        child: Icon(Icons.add_comment),
      ),
    );
  }

  @override
  void dispose() {
    _chatProvider.stopListeningToConversations();
    super.dispose();
  }
}
