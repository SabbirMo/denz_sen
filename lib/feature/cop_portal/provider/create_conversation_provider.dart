import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:flutter/material.dart';

class CreateConversationProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  int? createdConversationId;

  Future<bool> createConversation({
    required List<int> userIds,
    String? name,
    bool isGroup = false,
  }) async {
    isLoading = true;
    errorMessage = null;
    createdConversationId = null;
    notifyListeners();

    final url = Uri.parse('$baseUrl/api/v1/chat/conversations');
    final client = AuthenticatedClient();

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_ids': userIds,
          'name': name,
          'is_group': isGroup || userIds.length > 1,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        createdConversationId = data['id'];
        return true;
      } else {
        errorMessage = 'Failed to create conversation: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
