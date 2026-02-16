import 'dart:convert';
import 'dart:developer';
import 'package:denz_sen/core/http/authenticated_client.dart';
import '../../../core/base_url/base_url.dart';
import '../model/global_chat_model.dart';

class CopPortalCommsRepository {
  Future<List<GlobalChatMessage>> fetchGlobalChat() async {
    final client = AuthenticatedClient();
    try {
      final uri = Uri.parse('$baseUrl/api/v1/chat/global');

      log('Fetching global chat from: $uri');

      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      log('Chat Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => GlobalChatMessage.fromJson(e)).toList();
      } else {
        log('Failed to load chat: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching chat: $e');
      return [];
    }
  }

  Future<GlobalChatMessage?> sendMessage(String content) async {
    final client = AuthenticatedClient();
    try {
      final uri = Uri.parse('$baseUrl/api/v1/chat/global');

      log('Sending message to: $uri');

      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': content, 'attachment_urls': []}),
      );

      log('Send Message Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return GlobalChatMessage.fromJson(data);
      } else {
        log('Failed to send message: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error sending message: $e');
      return null;
    }
  }
}
