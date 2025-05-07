import 'chat_message.dart';

class ChatConversation {
  final int id;
  final int user1Id;
  final String user1Username;
  final int user2Id;
  final String user2Username;
  final DateTime lastActivity;
  final ChatMessage? lastMessage;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.user1Id,
    required this.user1Username,
    required this.user2Id,
    required this.user2Username,
    required this.lastActivity,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      user1Id: json['user1Id'],
      user1Username: json['user1Username'],
      user2Id: json['user2Id'],
      user2Username: json['user2Username'],
      lastActivity: DateTime.parse(json['lastActivity']),
      lastMessage: json['lastMessage'] != null ? ChatMessage.fromJson(json['lastMessage']) : null,
      unreadCount: json['unreadCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user1Username': user1Username,
      'user2Id': user2Id,
      'user2Username': user2Username,
      'lastActivity': lastActivity.toIso8601String(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
    };
  }
}
