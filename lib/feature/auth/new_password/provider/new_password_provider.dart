import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NewPasswordProvider extends ChangeNotifier {
  bool newPassword = true;
  bool newConfirmPassword = true;

  void toggleNewPasswordVisibility() {
    newPassword = !newPassword;
    notifyListeners();
  }

  void toggleNewConfirmPasswordVisibility() {
    newConfirmPassword = !newConfirmPassword;
    notifyListeners();
  }

  void resetVisibility() {
    newPassword = true;
    newConfirmPassword = true;
    notifyListeners();
  }

  //set new password

  bool isLoading = false;
  String? errorMessage;

  Future<bool> setNewPassword(
    String newPassword,
    String confirmPassword,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    debugPrint('🔄 Starting password reset...');
    final url = Uri.parse('$baseUrl/api/v1/auth/reset-password');

    try {
      final pref = await SharedPreferences.getInstance();
      final email = pref.getString('email');
      final token = pref.getString('reset_token');

      debugPrint('📧 Email: $email');
      debugPrint('🔑 Token: $token');

      final requestBody = {
        'email': email,
        'reset_token': token,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

      debugPrint('📤 Request URL: $url');
      debugPrint('📤 Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode != 200) {
        final responseData = jsonDecode(response.body);
        errorMessage =
            responseData['message'] ??
            'Failed to set new password. Please try again.';
        debugPrint('❌ Password reset failed: $errorMessage');
        isLoading = false;
        notifyListeners();
        return false;
      }

      debugPrint('✅ Password reset successful!');
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Exception during password reset: $e');
      isLoading = false;
      errorMessage = 'Failed to set new password. Please try again.';
      notifyListeners();
      return false;
    }
  }
}
