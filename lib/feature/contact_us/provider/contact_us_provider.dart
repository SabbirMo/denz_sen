import 'dart:convert';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContactUsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<bool> sendContactUs({
    required String subject,
    required String description,
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    debugPrint('🔄 Sending contact us message...');
    final url = Uri.parse('$baseUrl/api/v1/education/contact');
    debugPrint('API URL: $url');

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final requestBody = {'subject': subject, 'description': description};

      debugPrint('Request Body: $requestBody');

      final response = await http.post(
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
        debugPrint('✅ Contact message sent successfully: $data');
        successMessage = 'Your message has been sent successfully.';
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Failed to send message: ${response.statusCode}';
        debugPrint('❌ $errorMessage');
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      debugPrint('❌ Error sending contact message: $errorMessage');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
