import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadAllUsers();
  }

  Future<void> _searchUsers(String query) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.searchUsers(query);
  }

  Future<void> _startChat(UserModel user) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    final conversationId = await chatProvider.getOrCreateConversation(user.id);

    if (!mounted) return;
    Navigator.pop(context);

    if (conversationId != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(conversationId: conversationId, otherUser: user)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(chatProvider.error ?? 'Failed to start chat'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("New Chat"), centerTitle: false),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _loadUsers();
                        },
                        icon: Icon(Icons.clear),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  _loadUsers();
                } else {
                  _searchUsers(value);
                }
              },
            ),
          ),
          Expanded(
            child: chatProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : chatProvider.users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No Users found",
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: chatProvider.users.length,
                    itemBuilder: (context, index) {
                      final user = chatProvider.users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: user.avatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    user.avatarUrl!,
                                    fit: BoxFit.cover,
                                    width: 40,
                                    height: 40,
                                  ),
                                )
                              : Text(
                                  user.username[0].toUpperCase() ?? '?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        title: Text(user.username),
                        subtitle:
                            user.fullName != null && user.fullName!.isNotEmpty
                            ? Text(user.fullName!)
                            : null,
                        trailing: Icon(Icons.chat_bubble_outline),
                        onTap: () => _startChat(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
