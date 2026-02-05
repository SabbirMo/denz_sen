class GetProfileModel {
  final int id;
  final String fullName;
  final String email;
  final String copId;
  final String? avatarUrl;
  final double? currentLat;
  final double? currentLong;
  final int dispatchRadius;
  final bool isVerified;
  final String role;
  final String? phone;
  final String createdAt;
  final String? location;

  GetProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.copId,
    this.avatarUrl,
    this.currentLat,
    this.currentLong,
    required this.dispatchRadius,
    required this.isVerified,
    required this.role,
    this.phone,
    required this.createdAt,
    this.location,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) {
    return GetProfileModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      copId: json['cop_id'] ?? '',
      avatarUrl: json['avatar_url'],
      currentLat: json['current_lat']?.toDouble(),
      currentLong: json['current_long']?.toDouble(),
      dispatchRadius: (json['dispatch_radius'] as num?)?.toInt() ?? 0,
      isVerified: json['is_verified'] ?? false,
      role: json['role'] ?? '',
      phone: json['phone'],
      createdAt: json['created_at'] ?? '',
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'cop_id': copId,
      'avatar_url': avatarUrl,
      'current_lat': currentLat,
      'current_long': currentLong,
      'dispatch_radius': dispatchRadius,
      'is_verified': isVerified,
      'role': role,
      'phone': phone,
      'created_at': createdAt,
      'location': location,
    };
  }
}
