import 'dart:convert';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SingupProvider extends ChangeNotifier {
  bool isPassword = true;
  bool isConfirmPassword = true;

  void togglePasswordVisibility() {
    isPassword = !isPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPassword = !isConfirmPassword;
    notifyListeners();
  }

  void resetVisibility() {
    isPassword = true;
    isConfirmPassword = true;
    notifyListeners();
  }

  //Sign up API call
  bool isLoading = false;
  String? errorMessage;

  Future<void> signUp(
    String fullName,
    String email,
    String copID,
    String password,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'cop_id': copID,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('Sign up successful: $data');

        // Save email to shared preferences if available in response
        if (data['email'] != null) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', data['email']);
          debugPrint('Email saved: ${data['email']}');
        } else {
          // If email not in response, save the one user provided
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', email);
          debugPrint('User email saved: $email');
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);

          if (errorData['detail'] != null) {
            if (errorData['detail'] is List) {
              // detail is array (validation errors)
              final details = errorData['detail'] as List;
              if (details.isNotEmpty) {
                final firstError = details.first;
                errorMessage =
                    firstError['msg'] ?? 'Sign up failed. Please try again.';
              } else {
                errorMessage = 'Sign up failed. Please try again.';
              }
            } else if (errorData['detail'] is String) {
              // detail is string (general error message)
              errorMessage = errorData['detail'];
            } else {
              errorMessage = 'Sign up failed. Please try again.';
            }
          } else if (errorData['message'] != null) {
            // Handle simple message format
            errorMessage = errorData['message'];
          } else {
            errorMessage = 'Sign up failed. Please try again.';
          }
        } catch (_) {
          errorMessage =
              'Sign up failed. Server returned status ${response.statusCode}';
        }
        debugPrint('Sign up failed: $errorMessage');
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      // On error - show actual error for debugging
      isLoading = false;
      debugPrint('Sign up error: $e');

      // Check if it's a network error
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        errorMessage =
            'Cannot connect to server. Please check your network connection.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Please try again.';
      } else {
        errorMessage = 'Sign up failed: ${e.toString()}';
      }
      notifyListeners();
    }
  }
}
