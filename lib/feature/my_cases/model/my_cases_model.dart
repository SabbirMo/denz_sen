class MyCasesModel {
  final String caseNumber;
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final String status;
  final String eventDetails;
  final String actionsTaken;
  final int id;
  final int ownerId;
  final String createdAt;
  final String date;
  final String time;

  MyCasesModel({
    required this.caseNumber,
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.eventDetails,
    required this.actionsTaken,
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.date,
    required this.time,
  });

  factory MyCasesModel.fromJson(Map<String, dynamic> json) {
    return MyCasesModel(
      caseNumber: json['case_number'] ?? '',
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      eventDetails: json['event_details'] ?? '',
      actionsTaken: json['actions_taken'] ?? '',
      id: json['id'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
