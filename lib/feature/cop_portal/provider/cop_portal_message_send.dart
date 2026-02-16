import 'dart:convert';
import 'dart:io';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    final client = AuthenticatedClient();

    try {
      // Prepare fields
      final fields = {'content': content};

      // Prepare attachments
      final multipartFiles = <http.MultipartFile>[];
      if (attachments != null && attachments.isNotEmpty) {
        for (var file in attachments) {
          var stream = http.ByteStream(file.openRead());
          var length = await file.length();
          var multipartFile = http.MultipartFile(
            'files',
            stream,
            length,
            filename: file.path.split(Platform.pathSeparator).last,
          );
          multipartFiles.add(multipartFile);
          debugPrint('📎 Added file: ${multipartFile.filename}');
        }
        debugPrint('📎 Total files to upload: ${multipartFiles.length}');
      }

      final response = await client.multipart(
        'POST',
        url,
        fields: fields,
        files: multipartFiles,
      );

      debugPrint('📤 Response Status: ${response.statusCode}');
      debugPrint('📤 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        successMessage = 'Message sent successfully';
        debugPrint('✅ Message sent successfully');
        debugPrint('✅ Response data: $data');
        return true;
      } else {
        errorMessage = 'Failed to send message: ${response.statusCode}';
        debugPrint('❌ $errorMessage - Response: ${response.body}');
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
