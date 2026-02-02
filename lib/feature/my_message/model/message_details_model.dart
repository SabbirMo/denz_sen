class MessageDetailsModel {
  final int id;
  final int caseID;
  final int senderId;
  final String senderName;
  final String content;
  final List<String> attachmentUrls;
  final String createdAt;
  final String senderAvatar;
  final bool isMe;

  MessageDetailsModel({
    required this.id,
    required this.caseID,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.attachmentUrls,
    required this.createdAt,
    required this.senderAvatar,
    required this.isMe,
  });

  factory MessageDetailsModel.fromJson(Map<String, dynamic> json) {
    // Parse attachment_urls as a list
    List<String> urls = [];
    if (json['attachment_urls'] != null) {
      if (json['attachment_urls'] is List) {
        urls = (json['attachment_urls'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    return MessageDetailsModel(
      id: json['id'] ?? 0,
      caseID: json['case_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      senderName: json['sender_name'] ?? '',
      content: json['content'] ?? '',
      attachmentUrls: urls,
      createdAt: json['created_at'] ?? '',
      senderAvatar: json['sender_avatar'] ?? '',
      isMe: json['is_me'] ?? false,
    );
  }
}
