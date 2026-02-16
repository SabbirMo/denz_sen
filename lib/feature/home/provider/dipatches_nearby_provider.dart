import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:denz_sen/feature/home/model/dispatches_nearby_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DipatchesNearbyProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  List<DispatchesNearbyModel> dispatchesNearby = [];

  Future<bool> fetchDispatchesNearby() async {
    isLoading = true;
    errorMessage = null;
    dispatchesNearby = [];
    notifyListeners();

    final uri = Uri.parse('$baseUrl/api/v1/dispatches/nearby');
    final client = AuthenticatedClient();

    try {
      final response = await client.get(uri);

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('Response Data: $data');

        dispatchesNearby = data
            .map((item) => DispatchesNearbyModel.fromJson(item))
            .toList();

        // Save dispatch IDs to SharedPreferences
        await _saveDispatchIds(dispatchesNearby);

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage =
            'Failed to load nearby dispatches: ${response.statusCode}';
        debugPrint('❌ $errorMessage');
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Error fetching nearby dispatches: $e';
      debugPrint('❌ $errorMessage');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Save all dispatch IDs to SharedPreferences
  Future<void> _saveDispatchIds(List<DispatchesNearbyModel> dispatches) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = dispatches
          .where((d) => d.id != null)
          .map((d) => d.id.toString())
          .toList();

      await prefs.setStringList('nearby_dispatch_ids', ids);
      debugPrint('✅ Saved ${ids.length} dispatch IDs: $ids');
    } catch (e) {
      debugPrint('❌ Error saving dispatch IDs: $e');
    }
  }

  /// Get saved dispatch IDs from SharedPreferences
  static Future<List<String>?> getSavedDispatchIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('nearby_dispatch_ids');
    } catch (e) {
      debugPrint('❌ Error getting dispatch IDs: $e');
      return null;
    }
  }

  /// Clear all data (used when refreshing tokens)
  void clearData() {
    dispatchesNearby = [];
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}
