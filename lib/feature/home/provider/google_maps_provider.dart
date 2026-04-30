import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:flutter/material.dart';

class GoogleMapsProvider extends ChangeNotifier {
  String? errorMessage;
  bool isLoading = false;

  Map<String, dynamic>? userData;

  Future<bool> updateUserLocation(double latitude, double longitude) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final url = Uri.parse(
      '$baseUrl/api/v1/users/me/location?lat=$latitude&long=$longitude',
    );
    final client = AuthenticatedClient();

    try {
      final response = await client.patch(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        userData = data;
        debugPrint('Location updated successfully: $data');
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        if (data['detail'] != null) {
          if (data['detail'] is String) {
            errorMessage = data['detail'];
          } else if (data['detail'] is List) {
            final details = data['detail'] as List;
            errorMessage = details.isNotEmpty
                ? details[0]
                : 'An unknown error occurred.';
          } else {
            errorMessage = 'An unknown error occurred.';
          }
        } else {
          errorMessage = 'Failed to update location';
        }
        debugPrint('Error updating location: ${response.statusCode}');
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      debugPrint('Error updating location: $e');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<dynamic> activeCases = [];
  List<dynamic> dispatches = [];
  List<dynamic> memberLocations = [];

  Future<void> fetchMapPins() async {
    isLoading = true;
    notifyListeners();
    final client = AuthenticatedClient();

    try {
      // 1. Fetch Active Cases
      final casesRes = await client.get(Uri.parse('$baseUrl/api/v1/cases/?status=Active'));
      if (casesRes.statusCode == 200) {
        activeCases = jsonDecode(casesRes.body);
      }

      // 2. Fetch Dispatches
      final dispatchesRes = await client.get(Uri.parse('$baseUrl/api/v1/dispatches/'));
      if (dispatchesRes.statusCode == 200) {
        dispatches = jsonDecode(dispatchesRes.body);
      }

      // 3. Fetch Member Locations
      final membersRes = await client.get(Uri.parse('$baseUrl/api/v1/users/locations'));
      if (membersRes.statusCode == 200) {
        memberLocations = jsonDecode(membersRes.body);
      }
    } catch (e) {
      debugPrint('Error fetching map pins: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
