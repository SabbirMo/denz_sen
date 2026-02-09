import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/firebase/firebase_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NewDispatchDetailsAcceptProvider extends ChangeNotifier {
  bool isAccepting = false;
  String? errorMessage;
  bool? success;

  Future<bool> acceptDispatch() async {
    isAccepting = true;
    errorMessage = null;
    success = null;
    notifyListeners();

    try {
      final dispatchId = await FirebaseNotificationService.getSavedDispatchId();
      // Get access token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        errorMessage = 'No access token found';
        debugPrint('❌ $errorMessage');
        isAccepting = false;
        success = false;
        notifyListeners();
        return false;
      }

      // Make API call to accept dispatch
      final url = Uri.parse('$baseUrl/api/v1/dispatches/$dispatchId/accept');
      debugPrint('API URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        isAccepting = false;
        success = true;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Failed to accept dispatch';
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
