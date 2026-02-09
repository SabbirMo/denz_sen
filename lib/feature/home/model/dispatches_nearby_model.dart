class DispatchesNearbyModel {
  final int? id;
  final String? caseNumber;
  final double? lat;
  final double? long;
  final String? address;
  final String? description;
  final int? maxSlots;
  final String? status;
  final String? date;
  final int? slotsFilled;
  final String? formattedDate;
  final String? timeAgo;

  DispatchesNearbyModel({
    this.id,
    this.caseNumber,
    this.lat,
    this.long,
    this.address,
    this.description,
    this.maxSlots,
    this.status,
    this.date,
    this.slotsFilled,
    this.formattedDate,
    this.timeAgo,
  });

  factory DispatchesNearbyModel.fromJson(Map<String, dynamic> json) {
    return DispatchesNearbyModel(
      id: json['id'],
      caseNumber: json['case_number'],
      lat: json['lat']?.toDouble(),
      long: json['long']?.toDouble(),
      address: json['address'],
      description: json['description'],
      maxSlots: json['max_slots'],
      status: json['status'],
      date: json['date'],
      slotsFilled: json['slots_filled'],
      formattedDate: json['formatted_date'],
      timeAgo: json['time_ago'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'case_number': caseNumber,
      'lat': lat,
      'long': long,
      'address': address,
      'description': description,
      'max_slots': maxSlots,
      'status': status,
      'date': date,
      'slots_filled': slotsFilled,
      'formatted_date': formattedDate,
      'time_ago': timeAgo,
    };
  }
}
