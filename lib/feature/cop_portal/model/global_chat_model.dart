class GlobalChatMessage {
  final int? id;
  final int? caseId;
  final int senderId;
  final String content;
  final List<String> attachmentUrls;
  final String createdAt;
  final String senderName;
  final String senderAvatar;
  final bool isMe;

  GlobalChatMessage({
    this.id,
    this.caseId,
    required this.senderId,
    required this.content,
    required this.attachmentUrls,
    required this.createdAt,
    required this.senderName,
    required this.senderAvatar,
    required this.isMe,
  });

  factory GlobalChatMessage.fromJson(Map<String, dynamic> json) {
    return GlobalChatMessage(
      id: json['id'] as int?,
      caseId: json['case_id'] as int?,
      senderId: json['sender_id'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      attachmentUrls:
          (json['attachment_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['created_at'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? 'Unknown',
      senderAvatar: json['sender_avatar'] as String? ?? '',
      isMe: json['is_me'] as bool? ?? false,
    );
  }
}
