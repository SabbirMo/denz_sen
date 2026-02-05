import 'dart:convert';
import 'dart:io';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CopPortalMessageSendProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<bool> sendMessage({
    required String content,
    List<File>? attachments,
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    final url = Uri.parse('$baseUrl/api/v1/chat/global');

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // Create multipart request for file uploads
      var request = http.MultipartRequest('POST', url);
      request.headers['authorization'] = 'Bearer $token';

      // Add message content
      request.fields['content'] = content;

      // Add attachments if any
      if (attachments != null && attachments.isNotEmpty) {
        for (var i = 0; i < attachments.length; i++) {
          var file = attachments[i];
          var stream = http.ByteStream(file.openRead());
          var length = await file.length();

          var multipartFile = http.MultipartFile(
            'files',
            stream,
            length,
            filename: file.path.split(Platform.pathSeparator).last,
          );
          request.files.add(multipartFile);
          debugPrint('📎 Added file: ${multipartFile.filename}');
        }
        debugPrint('📎 Total files to upload: ${request.files.length}');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('📤 Response Status: ${response.statusCode}');
      debugPrint('📤 Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        successMessage = 'Message sent successfully';
        debugPrint('✅ Message sent successfully');
        debugPrint('✅ Response data: $data');
        return true;
      } else {
        errorMessage = 'Failed to send message: ${response.statusCode}';
        debugPrint('❌ $errorMessage - Response: $responseBody');
        return false;
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      debugPrint('❌ Error sending message: $errorMessage');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}
