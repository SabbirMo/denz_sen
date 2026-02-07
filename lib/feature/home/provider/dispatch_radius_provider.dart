import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DispatchRadiusProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  double? currentDispatchRadius;

  /// Update dispatch radius using PATCH method
  Future<bool> updateDispatchRadius(double dispatchRadius) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    debugPrint('🔄 Updating dispatch radius to: $dispatchRadius');

    // Send dispatch_radius as query parameter
    final url = Uri.parse(
      '$baseUrl/api/v1/users/me/dispatch-radius',
    ).replace(queryParameters: {'dispatch_radius': dispatchRadius.toString()});
    debugPrint('API URL: $url');

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        errorMessage = 'No access token found';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentDispatchRadius = dispatchRadius;
        successMessage = 'Dispatch radius updated successfully';
        isLoading = false;
        notifyListeners();
        debugPrint('✅ Dispatch radius updated successfully');
        return true;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        errorMessage =
            errorData['message'] ?? 'Failed to update dispatch radius';
        isLoading = false;
        notifyListeners();
        debugPrint('❌ Error: $errorMessage');
        return false;
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      isLoading = false;
      notifyListeners();
      debugPrint('❌ Exception: $e');
      return false;
    }
  }

  /// Clear error and success messages
  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}
