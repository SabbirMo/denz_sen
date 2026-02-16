import 'dart:convert';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:denz_sen/firebase/firebase_notification_service.dart';
import 'package:flutter/material.dart';

class NewDispatchDetailsAcceptProvider extends ChangeNotifier {
  bool isAccepting = false;
  String? errorMessage;
  bool? success;

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> acceptDispatch() async {
    isAccepting = true;
    errorMessage = null;
    success = null;
    notifyListeners();

    try {
      final dispatchId = await FirebaseNotificationService.getSavedDispatchId();
      final client = AuthenticatedClient();

      // Make API call to accept dispatch
      final url = Uri.parse('$baseUrl/api/v1/dispatches/$dispatchId/accept');
      debugPrint('API URL: $url');

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        isAccepting = false;
        success = true;
        notifyListeners();
        return true;
      } else {
        // Parse error response
        try {
          final responseData = jsonDecode(response.body);
          errorMessage = responseData['detail'] ?? 'Failed to accept dispatch';
        } catch (e) {
          errorMessage = 'Failed to accept dispatch';
        }
        debugPrint('❌ $errorMessage');
        isAccepting = false;
        success = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Error accepting dispatch: $e';
      debugPrint('❌ $errorMessage');
      isAccepting = false;
      success = false;
      notifyListeners();
      return false;
    }
  }
}
