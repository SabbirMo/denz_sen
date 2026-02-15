import 'dart:convert';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditInformationProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<bool> updateUserInformation({
    required String fullName,
    required String phone,
    String? avatarPath, // local file path (optional)
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    final Uri url = Uri.parse('$baseUrl/api/v1/users/me');

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        errorMessage = 'No access token found';
        isLoading = false;
        notifyListeners();
        return false;
      }

      // 🔥 Create Multipart Request
      var request = http.MultipartRequest('PATCH', url);

      // 🔐 Add Authorization Header
      request.headers['Authorization'] = 'Bearer $accessToken';

      // 📝 Add Form Fields
      request.fields['full_name'] = fullName;
      request.fields['phone'] = phone;

      // 📷 Add Image if exists
      if (avatarPath != null && avatarPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar', // backend field name
            avatarPath,
          ),
        );
      }

      // 🚀 Send Request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        successMessage = 'Profile updated successfully';
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        try {
          final responseBody = jsonDecode(response.body);
          errorMessage = responseBody['message'] ?? 'Failed to update profile';
        } catch (_) {
          errorMessage = 'Failed to update profile';
        }

        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Something went wrong: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}
