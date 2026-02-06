import 'dart:convert';
import 'dart:developer';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChangePasswordProvider extends ChangeNotifier {
  bool currentPassword = true;
  bool newPassword = true;
  bool confirmNewPassword = true;

  void toggleCurrentPasswordVisibility() {
    currentPassword = !currentPassword;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    newPassword = !newPassword;
    notifyListeners();
  }

  void toggleConfirmNewPasswordVisibility() {
    confirmNewPassword = !confirmNewPassword;
    notifyListeners();
  }

  void resetVisibility() {
    currentPassword = true;
    newPassword = true;
    confirmNewPassword = true;
    notifyListeners();
  }

  //change password API connect
  bool isLoading = false;
  String? errorMessage;
  bool? isSuccess;

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    isLoading = true;
    errorMessage = null;
    isSuccess = null;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      final uri = Uri.parse('$baseUrl/api/v1/users/me/password');

      final response = await http.post(
        uri,
        headers: {
          'authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_new_password': confirmNewPassword,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Password changed successfully: ${response.body}');
        isSuccess = true;
        errorMessage = null;
      } else {
        final responseBody = jsonDecode(response.body);
        errorMessage = responseBody['message'] ?? 'Failed to change password';
        isSuccess = false;
      }
    } catch (e) {
      errorMessage = 'An error occurred while changing the password.';
      isSuccess = false;
      log('Error changing password: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
