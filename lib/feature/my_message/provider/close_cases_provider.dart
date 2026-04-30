import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:flutter/material.dart';

class CloseCasesProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  bool? success;

  Future<void> closeCase(int caseId) async {
    isLoading = true;
    errorMessage = null;
    success = null;
    notifyListeners();
    final uri = Uri.parse('$baseUrl/api/v1/cases/$caseId/close');
    final client = AuthenticatedClient();

    try {
      debugPrint('Closing case $caseId...');
      debugPrint('API URL: $uri');

      final response = await client.post(uri);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Close case success: $data');
        success = true;
        isLoading = false;
        notifyListeners();
      } else {
        errorMessage = 'Failed to close case: ${response.statusCode}';
        debugPrint('❌ Close case failed: $errorMessage');
        success = false;
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      success = false;
      errorMessage = 'Failed to close case: $e';
      debugPrint('❌ Close case exception: $e');
      notifyListeners();
    }
  }

  Future<void> activateCase(int caseId) async {
    isLoading = true;
    errorMessage = null;
    success = null;
    notifyListeners();
    final uri = Uri.parse('$baseUrl/api/v1/cases/$caseId/status');
    final client = AuthenticatedClient();

    try {
      debugPrint('Activating case $caseId...');
      final response = await client.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'Active'}),
      );

      if (response.statusCode == 200) {
        success = true;
      } else {
        errorMessage = 'Failed to activate case: ${response.statusCode}';
        success = false;
      }
    } catch (e) {
      success = false;
      errorMessage = 'Exception: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
