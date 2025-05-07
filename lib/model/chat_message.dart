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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      senderUsername: json['senderUsername'],
      receiverId: json['receiverId'],
      receiverUsername: json['receiverUsername'],
      textContent: json['textContent'],
      timestamp: DateTime.parse(json['timestamp']),
      read: json['read'],
      attachments: (json['attachments'] as List)
          .map((e) => MessageAttachment.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'receiverId': receiverId,
      'receiverUsername': receiverUsername,
      'textContent': textContent,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'attachments': attachments.map((e) => e.toJson()).toList(),
    };
  }
}

