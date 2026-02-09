class DispatchDetailsModel {
  final int? dispatchId;
  final int? caseId;
  final String? caseNumber;
  final String? address;
  final String? description;
  final double? lat;
  final double? long;
  final String? type;
  final String? status;
  final String? createdAt;
  final String? date;
  final int? maxSlots;
  final int? slotsFilled;

  DispatchDetailsModel({
    this.dispatchId,
    this.caseId,
    this.caseNumber,
    this.address,
    this.description,
    this.lat,
    this.long,
    this.type,
    this.status,
    this.createdAt,
    this.date,
    this.maxSlots,
    this.slotsFilled,
  });

  factory DispatchDetailsModel.fromJson(Map<String, dynamic> json) {
    return DispatchDetailsModel(
      dispatchId: json['dispatch_id'] ?? json['id'],
      caseId: json['case_id'],
      caseNumber: json['case_number'],
      address: json['address'],
      description: json['description'],
      lat: json['lat']?.toDouble(),
      long: json['long']?.toDouble(),
      type: json['type'],
      status: json['status'],
      createdAt: json['created_at'] ?? json['date'],
      date: json['date'],
      maxSlots: json['max_slots'],
      slotsFilled: json['slots_filled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dispatch_id': dispatchId,
      'case_id': caseId,
      'case_number': caseNumber,
      'address': address,
      'description': description,
      'lat': lat,
      'long': long,
      'type': type,
      'status': status,
      'created_at': createdAt,
      'date': date,
      'max_slots': maxSlots,
      'slots_filled': slotsFilled,
    };
  }
}
