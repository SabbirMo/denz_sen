import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/feature/home/model/get_profile_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final url = Uri.parse('$baseUrl/api/v1/users/me');

      final response = await http.get(
        url,
        headers: {
          'authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
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
}
