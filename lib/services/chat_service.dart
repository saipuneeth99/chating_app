import 'package:chat_app/models/conversation_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) throw Exception('No user logged in');
      final data = await _supabase
          .from('profiles')
          .select()
          .ilike('username', '%$query%')
          .neq('id', currentUser)
          .limit(20);

      return (data as List).map((json) => UserModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) throw Exception('No user logged in');
      final data = await _supabase
          .from('profiles')
          .select()
          .neq('id', currentUser)
          .order('username');

      return (data as List).map((json) => UserModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  Future<String> getOrCreateConversation(String otherUserId) async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) throw Exception('No user logged in');

      // Get all conversation IDs for current user
      final currentUserConversations = await _supabase
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', currentUser);

      // For each conversation, check if otherUserId is also a participant
      for (var conv in currentUserConversations) {
        final conversationId = conv['conversation_id'];
        final otherUserInConv = await _supabase
            .from('conversation_participants')
            .select()
            .eq('conversation_id', conversationId)
            .eq('user_id', otherUserId);
        
        if (otherUserInConv.isNotEmpty) {
          return conversationId;
        }
      }

      // No existing conversation found, create a new one
      final conversationData = await _supabase
          .from('conversations')
          .insert({})
          .select()
          .single();

      final conversationId = conversationData['id'];
      
      // Add both participants
      await _supabase.from('conversation_participants').insert([
        {'conversation_id': conversationId, 'user_id': currentUser},
        {'conversation_id': conversationId, 'user_id': otherUserId},
      ]);
      
      return conversationId;
    } catch (e) {
      throw Exception('Failed to get or create conversation: $e');
    }
  }

  Future<List<ConversationModel>> getConversations() async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) throw Exception('No user logged in');

      final participantData = await _supabase
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', currentUser);

      List<ConversationModel> conversations = [];
      for (var participant in participantData) {
        final conversationId = participant['conversation_id'];
        final conversationData = await _supabase
            .from('conversations')
            .select()
            .eq('id', conversationId)
            .single();
        ConversationModel conversation = ConversationModel.fromJson(
          conversationData,
        );
        final otherUserData = await _supabase
            .from('conversation_participants')
            .select('user_id, profiles(*)')
            .eq('conversation_id', conversationId)
            .neq('user_id', currentUser)
            .single();

        conversation.otherUser = UserModel.fromMap(otherUserData['profiles']);

        final lastMessageData = await _supabase
            .from('messages')
            .select()
            .eq('conversation_id', conversationId)
            .order('created_at', ascending: false)
            .limit(1);

        if (lastMessageData.isNotEmpty) {
          conversation.lastMessage = MessageModel.fromJson(
            lastMessageData.first,
          );
        }
        final unreadData = await _supabase
            .from('messages')
            .select('id')
            .eq('conversation_id', conversationId)
            .eq('is_read', false)
            .neq('sender_id', currentUser)
            .count(CountOption.exact);
        conversation.unreadCount = unreadData.count;

        conversations.add(conversation);
      }

      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return conversations;
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final data = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);
      return (data as List).map((json) {
        return MessageModel.fromMap(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  Future<MessageModel?> sendMessage(
    String conversationId,
    String content,
  ) async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) throw Exception('No user logged in');

      final messageData = await _supabase
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': currentUser,
            'content': content,
            'is_read': false,
          })
          .select()
          .single();

      return MessageModel.fromMap(messageData);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final currentUser = currentUserId;
      if (currentUser == null) throw Exception('No user logged in');

      print('📍 Marking messages as read for conversation: $conversationId');

      // Mark all unread messages in this conversation as read
      final response = await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', currentUser)
          .eq('is_read', false);
      
      print('✓ Marked as read: $response');
      
      // Update conversation timestamp to trigger stream
      await _supabase
          .from('conversations')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', conversationId);
      
      print('✓ Updated conversation timestamp');
    } catch (e) {
      print('✗ Error marking messages as read: $e');
      throw Exception('Failed to mark message as read: $e');
    }
  }
  Stream<MessageModel> listenToMessages(String conversationId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((data) => data.map((json) => MessageModel.fromMap(json)).toList())
        .expand((messages) => messages);
  }
  Stream<List<Map<String, dynamic>>> listenToConversations() {
    final currentUser = currentUserId;
    if (currentUser == null) {
      return const Stream.empty();
    }
    return _supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false);
  }
}
