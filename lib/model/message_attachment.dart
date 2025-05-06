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
}
