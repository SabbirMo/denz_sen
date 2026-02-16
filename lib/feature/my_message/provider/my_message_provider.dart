import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:denz_sen/feature/my_message/model/my_message_model.dart';
import 'package:flutter/material.dart';

class MyMessageProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<MyMessageModel> messages = [];

  Future<List<MyMessageModel>> fatchMessage() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseUrl/api/v1/chat/my-conversations');
    final client = AuthenticatedClient();

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        messages = data.map((json) => MyMessageModel.fromJson(json)).toList();
        debugPrint(
          '✅ Messages fetched successfully: ${messages.length} messages',
        );
        return messages;
      } else {
        errorMessage = 'Failed to load messages: ${response.statusCode}';
        debugPrint(errorMessage);
        return [];
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      debugPrint(errorMessage);
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
