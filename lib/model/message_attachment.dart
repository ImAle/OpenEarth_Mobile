import 'attachment_type.dart';

class MessageAttachment {
  final int? id;
  final AttachmentType type;
  final String content;
  final String? metadata;

  MessageAttachment({
    this.id,
    required this.type,
    required this.content,
    this.metadata,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'],
      type: AttachmentType.values.firstWhere((e) => e.toString() == 'AttachmentType.${json['type']}'),
      content: json['content'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'metadata': metadata,
    };
  }
}
