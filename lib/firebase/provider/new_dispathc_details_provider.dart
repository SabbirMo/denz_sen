import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:denz_sen/firebase/firebase_notification_service.dart';
import 'package:denz_sen/firebase/model/dispatch_details_model.dart';
import 'package:flutter/material.dart';

class NewDispathcDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  DispatchDetailsModel? dispatchDetails;

  /// Fetch dispatch details using saved dispatch_id from SharedPreferences
  Future<bool> fetchDispatchDetails() async {
    isLoading = true;
    errorMessage = null;
    dispatchDetails = null;
    notifyListeners();

    try {
      // Get saved dispatch_id from SharedPreferences
      final dispatchId = await FirebaseNotificationService.getSavedDispatchId();

      if (dispatchId == null || dispatchId.isEmpty) {
        errorMessage = 'No dispatch ID found';
        debugPrint('❌ $errorMessage');
        isLoading = false;
        notifyListeners();
        return false;
      }

      debugPrint('🔄 Fetching dispatch details for ID: $dispatchId');
      final client = AuthenticatedClient();

      // Make API call
      final url = Uri.parse('$baseUrl/api/v1/dispatches/$dispatchId');
      debugPrint('API URL: $url');

      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        dispatchDetails = DispatchDetailsModel.fromJson(data);
        debugPrint('✅ Dispatch details fetched successfully');
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        final responseBody = jsonDecode(response.body);
        errorMessage =
            responseBody['message'] ?? 'Failed to fetch dispatch details';
        debugPrint('❌ $errorMessage');
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      debugPrint('❌ Error fetching dispatch details: $errorMessage');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear dispatch details
  void clearDispatchDetails() {
    dispatchDetails = null;
    errorMessage = null;
    notifyListeners();
  }
}
