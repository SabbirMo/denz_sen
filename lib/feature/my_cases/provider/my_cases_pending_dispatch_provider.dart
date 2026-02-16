import 'dart:convert';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:flutter/material.dart';

class MyCasesPendingDispatchProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  bool? success;

  Future<void> pendingDispatchCases(int caseId) async {
    isLoading = true;
    errorMessage = null;
    success = null;
    notifyListeners();
    final client = AuthenticatedClient();

    try {
      final uri = Uri.parse('$baseUrl/api/v1/cases/$caseId/dispatch');

      final response = await client.post(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Pending dispatch case response: $data');
        success = true;
      } else {
        errorMessage = 'Failed to dispatch case: ${response.statusCode}';
        success = false;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to fetch pending dispatch cases';
      success = false;
      notifyListeners();
    }
  }
}
