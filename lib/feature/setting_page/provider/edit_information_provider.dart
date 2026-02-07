import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditInformationProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<bool> updateUserInformation({
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    debugPrint('🔄 Updating user information...');
    final url = Uri.parse('$baseUrl/api/v1/users/me');
    debugPrint('API URL: $url');

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        errorMessage = 'No access token found';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final requestBody = {
        'full_name': fullName,
        'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      debugPrint('Request Body: $requestBody');

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('✅ User information updated successfully: $data');
        successMessage = 'Profile updated successfully';
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        final responseBody = jsonDecode(response.body);
        errorMessage = responseBody['message'] ?? 'Failed to update profile';
        debugPrint('❌ $errorMessage');
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      debugPrint('❌ Error updating user information: $errorMessage');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}
