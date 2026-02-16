import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:flutter/material.dart';

class DispatchRadiusProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  double _dispatchRadius = 0.0;

  double get dispatchRadius => _dispatchRadius;

  /// Set dispatch radius value locally (for slider movement)
  void setDispatchRadius(double value) {
    _dispatchRadius = value;
    notifyListeners();
  }

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
    final client = AuthenticatedClient();
    debugPrint('API URL: $url');

    try {
      final response = await client.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _dispatchRadius = dispatchRadius;
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
