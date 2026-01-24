import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SigninProvider extends ChangeNotifier {
  bool isPassword = true;

  void togglePasswordVisibility() {
    isPassword = !isPassword;
    notifyListeners();
  }

  void resetVisibility() {
    isPassword = true;
    notifyListeners();
  }

  //signin API integration will be here

  bool isLoading = false;
  String? errorMessage;

  Future<bool> signin(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final uri = Uri.parse('$baseUrl/api/v1/auth/login');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('Signin Successful: $data');
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
      debugPrint('Signin Error: $e');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
