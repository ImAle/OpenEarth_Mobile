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
}
