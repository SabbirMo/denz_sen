import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:denz_sen/feature/my_message/model/message_details_model.dart';
import 'package:flutter/material.dart';

class MessageDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<MessageDetailsModel> messages = [];

  Future<List<MessageDetailsModel>> fetchMessageDetails(int caseId) async {
    isLoading = true;
    notifyListeners();
    final url = Uri.parse('$baseUrl/api/v1/chat/$caseId/messages');
    final client = AuthenticatedClient();
    debugPrint('🔄 Fetching message details for case ID: $caseId');

    try {
      final response = await client.get(url);

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
