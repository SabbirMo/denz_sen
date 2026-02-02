import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/feature/my_message/model/my_message_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyMessageProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<MyMessageModel> messages = [];

  Future<List<MyMessageModel>> fatchMessage() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseUrl/api/v1/chat/my-conversations');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        url,
        headers: {'authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        messages = data.map((json) => MyMessageModel.fromJson(json)).toList();
        debugPrint('Messages fetched: $messages');
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
