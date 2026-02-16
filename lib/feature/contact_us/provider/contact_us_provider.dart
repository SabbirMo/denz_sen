import 'dart:convert';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:flutter/material.dart';

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
    final client = AuthenticatedClient();
    debugPrint('API URL: $url');

    try {
      final requestBody = {'subject': subject, 'description': description};

      debugPrint('Request Body: $requestBody');

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
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
