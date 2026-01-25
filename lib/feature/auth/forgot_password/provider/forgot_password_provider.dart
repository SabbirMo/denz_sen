import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> sendForgotPasswordEmail(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final uri = Uri.parse('$baseUrl/api/v1/auth/forgot-password');
    debugPrint('API URL: $uri');

    try {
      final requestBody = jsonEncode({'email': email});
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
        debugPrint('Forgot Password Email Sent Successfully: $data');
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        if (data['detail'] != null) {
          if (data['detail'] is String) {
            errorMessage = data['detail'];
          } else if (data['detail'] is List) {
            final details = data['detail'] as List;
            errorMessage = details.isNotEmpty
                ? details[0]
                : 'An unknown error occurred.';
          } else {
            errorMessage = 'An unknown error occurred.';
          }
        } else {
          errorMessage = 'An unknown error occurred.';
        }
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error during forgot password email sending: $e');
      errorMessage = 'Failed to connect to the server. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
