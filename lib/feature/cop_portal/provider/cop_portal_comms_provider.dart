import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import '../model/global_chat_model.dart';
import '../repository/cop_portal_comms_repository.dart';

class CopPortalCommsProvider extends ChangeNotifier {
  final CopPortalCommsRepository _repository = CopPortalCommsRepository();
  List<GlobalChatMessage> _messages = [];
  bool _isLoading = false;
  bool isConnected = false;
  IOWebSocketChannel? _channel;
  bool shouldReconnect = false;

  List<GlobalChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await fetchMessages();
    // WebSocket disabled to improve performance
    // Using periodic refresh instead
  }

  Future<void> fetchMessages() async {
    _isLoading = true;
    notifyListeners();

    List<GlobalChatMessage> fetchedMessages = await _repository
        .fetchGlobalChat();

    // Sort messages: Newest first (Descending order of created_at)
    fetchedMessages.sort((a, b) {
      try {
        return DateTime.parse(
          b.createdAt,
        ).compareTo(DateTime.parse(a.createdAt));
      } catch (e) {
        return 0;
      }
    });

    _messages = fetchedMessages;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final sentMessage = await _repository.sendMessage(content);

    if (sentMessage != null) {
      // Add message optimistically
      _messages.insert(0, sentMessage);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    shouldReconnect = false;
    _channel?.sink.close();
    super.dispose();
  }
}
