import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/feature/my_message/model/message_details_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MessageDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<MessageDetailsModel> messages = [];

  Future<List<MessageDetailsModel>> fetchMessageDetails(int caseId) async {
    isLoading = true;
    notifyListeners();
    final url = Uri.parse('$baseUrl/api/v1/chat/$caseId/messages');
    debugPrint('🔄 Fetching message details for case ID: $caseId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        url,
        headers: {'authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        messages = data.map((e) => MessageDetailsModel.fromJson(e)).toList();
        return messages;
      } else {
        errorMessage = 'Failed to load messages: ${response.statusCode}';
        debugPrint(' $errorMessage');
        return [];
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      debugPrint(' $errorMessage');
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
      debugPrint(
        '🏁 Loading complete. isLoading: $isLoading, messages count: ${messages.length}',
      );
    }
  }
}
