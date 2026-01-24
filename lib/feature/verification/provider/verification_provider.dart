import 'dart:convert';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerificationProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;
  String? name;
  String? email;

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('full_name');
    email = prefs.getString('email');
    notifyListeners();
  }

  Future<bool> verifyOtp(String email, String otp) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final uri = Uri.parse('$baseUrl/api/v1/auth/verify-otp');
    debugPrint('API URL: $uri');

    try {
      final requestBody = jsonEncode({'email': email, 'otp': otp});
      debugPrint('Request Body: $requestBody');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('OTP Verification Successful: $data');
        // Save email or token if needed
        if (data['email'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', data['email']);
          debugPrint('Email saved: ${data['email']}');
        }

        isSuccess = true;
        return true;
      } else {
        try {
          final data = jsonDecode(response.body);

          // Handle different error response formats
          if (data['detail'] != null) {
            if (data['detail'] is String) {
              errorMessage = data['detail'];
            } else if (data['detail'] is List) {
              final details = data['detail'] as List;
              errorMessage = details.isNotEmpty
                  ? (details.first['msg'] ?? 'OTP verification failed')
                  : 'OTP verification failed';
            } else {
              errorMessage = 'OTP verification failed';
            }
          } else if (data['message'] != null) {
            errorMessage = data['message'];
          } else {
            errorMessage = 'OTP verification failed';
          }
        } catch (_) {
          errorMessage =
              'OTP verification failed. Status: ${response.statusCode}';
        }

        debugPrint('OTP Verification Failed: $errorMessage');
        return false;
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      debugPrint('OTP Verification Error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
      debugPrint('========== OTP Verification Ended ==========');
    }
  }
}
