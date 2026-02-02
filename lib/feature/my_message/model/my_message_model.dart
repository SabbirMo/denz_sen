class MyMessageModel {
  final int id;
  final String caseNumber;
  final String caseStatus;
  final String lastMessage;
  final String lastSender;
  final String lastActivity;

  MyMessageModel({
    required this.id,
    required this.caseNumber,
    required this.caseStatus,
    required this.lastMessage,
    required this.lastSender,
    required this.lastActivity,
  });

  factory MyMessageModel.fromJson(Map<String, dynamic> json) {
    return MyMessageModel(
      id: json['case_id'] ?? 0,
      caseNumber: json['case_number'] ?? '',
      caseStatus: json['case_status'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastSender: json['last_sender'] ?? '',
      lastActivity: json['last_activity'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseNumber': caseNumber,
      'caseStatus': caseStatus,
      'lastMessage': lastMessage,
      'lastSender': lastSender,
      'lastActivity': lastActivity,
    };
  }

  @override
  String toString() {
    return 'MyMessageModel(id: $id, caseNumber: $caseNumber, caseStatus: $caseStatus, lastMessage: $lastMessage, lastSender: $lastSender, lastActivity: $lastActivity)';
  }
}
