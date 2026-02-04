import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CloseCasesProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<void> caseClose(int caseId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final uri = Uri.parse('$baseUrl/api/v1/cases/$caseId/close');

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      debugPrint('Closing case $caseId...');
      debugPrint('API URL: $uri');

      final response = await http.post(
        uri,
        headers: {'authorization': 'Bearer $accessToken'},
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Close case success: $data');
        isLoading = false;
        notifyListeners();
      } else {
        errorMessage = 'Failed to close case: ${response.statusCode}';
        debugPrint('❌ Close case failed: $errorMessage');
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to close case: $e';
      debugPrint('❌ Close case exception: $e');
      notifyListeners();
    }
  }
}
