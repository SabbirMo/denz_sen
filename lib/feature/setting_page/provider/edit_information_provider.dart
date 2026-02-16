import 'dart:convert';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    final client = AuthenticatedClient();

    try {
      // 📝 Prepare fields
      final fields = {'full_name': fullName, 'phone': phone};

      // 📷 Add Image if exists
      final files = <http.MultipartFile>[];
      if (avatarPath != null && avatarPath.isNotEmpty) {
        files.add(
          await http.MultipartFile.fromPath(
            'avatar', // backend field name
            avatarPath,
          ),
        );
      }

      // 🚀 Send Request
      final response = await client.multipart(
        'PATCH',
        url,
        fields: fields,
        files: files,
      );

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
