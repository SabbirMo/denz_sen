import 'dart:convert';
import 'dart:io';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportSubmitProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  double? latitude;
  double? longitude;
  String? selectedAddress;

  /// Set location from map picker
  void setLocation(double lat, double lng, String address) {
    latitude = lat;
    longitude = lng;
    selectedAddress = address;
    notifyListeners();
    debugPrint('✅ Location saved: Lat: $lat, Lng: $lng');
  }

  /// Clear location
  void clearLocation() {
    latitude = null;
    longitude = null;
    selectedAddress = null;
    notifyListeners();
  }

  /// Submit report to backend
  Future<bool> submitReport({
    required String eventDate, // YYYY-MM-DD format
    required String details,
    required String actionsTaken,
    String? address,
    String? state,
    String? city,
    String? zipCode,
    List<File>? files,
  }) async {
    if (latitude == null || longitude == null) {
      errorMessage = 'Please select location on map';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    debugPrint('🚀 Submitting report...');
    debugPrint('📍 Latitude: $latitude');
    debugPrint('📍 Longitude: $longitude');
    debugPrint('📅 Event Date: $eventDate');

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        errorMessage = 'No access token found';
        isLoading = false;
        notifyListeners();
        return false;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/reports/'),
      );

      request.headers['Authorization'] = 'Bearer $accessToken';

      // Mandatory fields
      request.fields['event_date'] = eventDate;
      request.fields['details'] = details;
      request.fields['actions_taken'] = actionsTaken;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      // Optional fields (auto-filled from GPS if empty)
      if (address != null && address.isNotEmpty) {
        request.fields['address'] = address;
      }
      if (state != null && state.isNotEmpty) {
        request.fields['state'] = state;
      }
      if (city != null && city.isNotEmpty) {
        request.fields['city'] = city;
      }
      if (zipCode != null && zipCode.isNotEmpty) {
        request.fields['zip_code'] = zipCode;
      }

      // Add files (images/videos)
      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          request.files.add(
            await http.MultipartFile.fromPath('files', file.path),
          );
        }
        debugPrint('📎 Attached ${files.length} files');
      }

      debugPrint('📤 Sending request to: ${request.url}');
      debugPrint('📋 Fields: ${request.fields}');

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: $responseBody');

      isLoading = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        successMessage = 'Report submitted successfully';
        clearLocation(); // Clear location after success
        notifyListeners();
        debugPrint('✅ Report submitted successfully');
        return true;
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(responseBody);
          errorMessage =
              errorData['detail'] ??
              errorData['message'] ??
              'Failed to submit report';
        } catch (e) {
          errorMessage = 'Failed to submit report';
        }
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
