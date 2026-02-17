import 'dart:async';

import 'package:chat_app/models/conversation_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _conversationSubscription;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    try {
      var allConversations = await _chatService.getConversations();
      
      // Remove duplicate conversations with the same user (keep the latest one)
      final Map<String, ConversationModel> deduped = {};
      for (var conv in allConversations) {
        final key = conv.otherUser?.id ?? 'unknown';
        if (deduped[key] == null || 
            conv.updatedAt.isAfter(deduped[key]!.updatedAt)) {
          deduped[key] = conv;
        }
      }
      
      _conversations = deduped.values.toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchUsers(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (query.isEmpty) {
        _users = await _chatService.getAllUsers();
      } else {
        _users = await _chatService.searchUsers(query);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllUsers() async {
    _isLoading = true;
    _error = null;
    //notifyListeners();
    try {
      _users = await _chatService.getAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getOrCreateConversation(String otherUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final conversationId = await _chatService.getOrCreateConversation(
        otherUserId,
      );
      _isLoading = false;
      notifyListeners();
      return conversationId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadMessages(String conversationId) async {
    _isLoading = true;
    _error = null;
    //notifyListeners();
    try {
      _messages = await _chatService.getMessages(conversationId);
      await _chatService.markMessagesAsRead(conversationId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String conversationId, String content) async {
    try {
      final message = await _chatService.sendMessage(conversationId, content);
      _messages.add(message!);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await _chatService.markMessagesAsRead(conversationId);
      notifyListeners(); // Update UI after marking as read
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void listenToMessages(String conversationId) {
    _messageSubscription = _chatService.listenToMessages(conversationId).listen(
      (message) {
        final existingIndex = _messages.indexWhere((m) => m.id == message.id);
        if (existingIndex == -1) {
          _messages.add(message);
          notifyListeners();
          if (message.senderId != _chatService.currentUserId) {
            _chatService.markMessagesAsRead(conversationId);
          }
        } else {
          _messages[existingIndex] = message;
          notifyListeners();
        }
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }
  void stopListeningToMessages() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  void listenToConversations(){
    _conversationSubscription?.cancel();
    _conversationSubscription = _chatService.listenToConversations().listen(
      (data) {
         loadConversations();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      }
    );
  }
  void stopListeningToConversations() {
    _conversationSubscription?.cancel();
    _conversationSubscription = null;
  }
  void clearMessages() {
    _messages = [];
    notifyListeners();  
  }
  void clearError(){
    _error = null;
    notifyListeners();
  }
  @override
  void dispose() {
    _messageSubscription?.cancel();
    _conversationSubscription?.cancel();
    super.dispose();
  }
}