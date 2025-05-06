import 'message_attachment.dart';

class ChatMessage {
  final int? id;
  final int senderId;
  final String senderUsername;
  final int receiverId;
  final String receiverUsername;
  final String? textContent;
  final DateTime timestamp;
  final bool read;
  final List<MessageAttachment> attachments;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.senderUsername,
    required this.receiverId,
    required this.receiverUsername,
    this.textContent,
    required this.timestamp,
    required this.read,
    required this.attachments,
  });
}
