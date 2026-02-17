import 'package:postgrest/src/types.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  String? senderUsername;
  String? senderAvatarUrl;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.senderUsername,
    this.senderAvatarUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      senderUsername: json['sender_username'] as String?,
      senderAvatarUrl: json['sender_avatar_url'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sender_username': senderUsername,
      'sender_avatar_url': senderAvatarUrl,
    };
  }
 
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? senderUsername,
    String? senderAvatarUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      senderUsername: senderUsername ?? this.senderUsername,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
    );
  }
   @override String toString() {
    return 'MessageModel(id: $id, senderId: $senderId, content: ${content.substring(0, content.length > 20? 20 : content.length)}...)';
  }
  @override bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is MessageModel && other.id == id;
  }
  @override int get hashCode => id.hashCode;

  static MessageModel? fromJson(PostgrestMap first) {
    return MessageModel.fromMap(first);
  }
}