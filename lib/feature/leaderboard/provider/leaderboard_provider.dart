import 'dart:convert';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:flutter/material.dart';

class Badge {
  final String name;
  final int minPoints;
  final bool isUnlocked;

  Badge({
    required this.name,
    required this.minPoints,
    required this.isUnlocked,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      name: json['name'] ?? '',
      minPoints: json['min_points'] ?? 0,
      isUnlocked: json['is_unlocked'] ?? false,
    );
  }
}

class GamificationData {
  final String currentRank;
  final int currentPoints;
  final int nextRankPoints;
  final double progressPercent;
  final int pointsNeeded;
  final List<Badge> badges;

  GamificationData({
    required this.currentRank,
    required this.currentPoints,
    required this.nextRankPoints,
    required this.progressPercent,
    required this.pointsNeeded,
    required this.badges,
  });

  factory GamificationData.fromJson(Map<String, dynamic> json) {
    return GamificationData(
      currentRank: json['current_rank'] ?? 'Observer I',
      currentPoints: json['current_points'] ?? 0,
      nextRankPoints: json['next_rank_points'] ?? 100,
      progressPercent: (json['progress_percent'] ?? 0).toDouble(),
      pointsNeeded: json['points_needed'] ?? 100,
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map((badge) => Badge.fromJson(badge))
              .toList() ??
          [],
    );
  }
}

class LeaderboardProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  GamificationData? gamificationData;

  /// Fetch gamification data
  Future<bool> fetchGamificationData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    debugPrint('🔄 Fetching gamification data...');

    final url = Uri.parse('$baseUrl/api/v1/users/gamification');
    final client = AuthenticatedClient();
    debugPrint('API URL: $url');

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        gamificationData = GamificationData.fromJson(data);
        isLoading = false;
        notifyListeners();
        debugPrint('✅ Gamification data fetched successfully');
        return true;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        errorMessage =
            errorData['message'] ?? 'Failed to fetch gamification data';
        isLoading = false;
        notifyListeners();
        debugPrint('❌ Error: $errorMessage');
        return false;
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      isLoading = false;
      notifyListeners();
      debugPrint('❌ Exception: $e');
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
