import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:denz_sen/feature/home/model/get_profile_model.dart';
import 'package:flutter/foundation.dart';

class ProfileShowProvider extends ChangeNotifier {
  String? errorMessage;
  bool isLoading = false;
  String? successMessage;

  GetProfileModel? profile;

  Future<GetProfileModel?> showProfile() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
    final client = AuthenticatedClient();

    try {
      final url = Uri.parse('$baseUrl/api/v1/users/me');

      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        debugPrint('Profile data: $jsonData');

        profile = GetProfileModel.fromJson(jsonData);
        successMessage = 'Profile loaded successfully.';

        isLoading = false;
        notifyListeners();
        return profile;
      } else {
        errorMessage = 'Failed to load profile: ${response.statusCode}';
        debugPrint('❌ $errorMessage');

        isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      errorMessage = 'Failed to load profile. Please try again later.';
      debugPrint('❌ Error: $e');

      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Clear all data (used when refreshing tokens)
  void clearData() {
    profile = null;
    isLoading = false;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}
