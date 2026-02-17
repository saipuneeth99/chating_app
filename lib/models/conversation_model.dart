import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:postgrest/src/types.dart';

class ConversationModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel? otherUser;
  MessageModel? lastMessage;
  int unreadCount;

  ConversationModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'unread_count': unreadCount,
    };
  }
  ConversationModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? otherUser,
    MessageModel? lastMessage,
    int? unreadCount,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      otherUser: otherUser ?? this.otherUser,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
  @override
  String toString() {
    return 'ConversationModel{id: $id, otherUser: $otherUser, lastMessage: $lastMessage}';
  }
  @override bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ConversationModel && other.id == id;
  }
  @override int get hashCode => id.hashCode;

  static ConversationModel fromJson(PostgrestMap conversationData) {
    return ConversationModel.fromMap(conversationData);
  }
}