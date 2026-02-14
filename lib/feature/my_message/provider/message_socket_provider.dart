import 'dart:convert';
import 'dart:io';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageSocketProvider extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool isConnected = false;
  String? errorMessage;
  bool hasNewMessage = false; // Flag to trigger refresh

  // Callback for when new message arrives
  Function()? onNewMessage;

  // Connect to WebSocket
  Future<void> connect(int caseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      // WebSocket URL: ws://10.10.13.20:8000/api/v1/chat/ws/{case_id}?token=YOUR_JWT_TOKEN

      final uri = Uri.parse('$wsBaseUrl/api/v1/chat/ws/$caseId?token=$token');

      _channel = WebSocketChannel.connect(uri);
      isConnected = true;
      debugPrint('🟢 WebSocket connected to: $uri');

      // Listen for incoming messages
      _channel!.stream.listen(
        (data) {
          _handleIncomingMessage(data);
        },
        onError: (error) {
          debugPrint('❌ WebSocket error: $error');
          errorMessage = 'Connection error: $error';
          isConnected = false;
          // Schedule notification for next frame to avoid build errors
          Future.microtask(() => notifyListeners());
        },
        onDone: () {
          debugPrint('🔴 WebSocket connection closed');
          isConnected = false;
          // Schedule notification for next frame to avoid build errors
          Future.microtask(() => notifyListeners());
        },
      );

      // Schedule notification for next frame to avoid build errors
      Future.microtask(() => notifyListeners());
    } catch (e) {
      debugPrint('❌ WebSocket connection failed: $e');
      errorMessage = 'Failed to connect: $e';
      isConnected = false;
      // Schedule notification for next frame to avoid build errors
      Future.microtask(() => notifyListeners());
    }
  }

  // Handle incoming message
  void _handleIncomingMessage(dynamic data) {
    try {
      final jsonData = jsonDecode(data);
      debugPrint('📩 Received WebSocket message: $jsonData');

      // Handle different message types from backend
      if (jsonData['type'] == 'new_message' ||
          jsonData['event'] == 'new_message' ||
          jsonData['action'] == 'new_message') {
        // Trigger refresh callback instead of managing messages
        debugPrint('✅ New message received, triggering UI refresh');
        hasNewMessage = true;
        if (onNewMessage != null) {
          onNewMessage!();
        }
        // Schedule notification for next frame to avoid build errors
        Future.microtask(() => notifyListeners());
      } else {
        // Log unhandled message types for debugging
        debugPrint(
          'ℹ️ Unhandled WebSocket message type: ${jsonData['type'] ?? jsonData['event'] ?? jsonData['action']}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing WebSocket message: $e');
      debugPrint('Raw data: $data');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Send message through WebSocket
  Future<void> sendMessage({
    required String content,
    List<File>? attachments,
  }) async {
    if (!isConnected || _channel == null) {
      errorMessage = 'Not connected to chat';
      Future.microtask(() => notifyListeners());
      return;
    }

    try {
      // For now, send text messages through WebSocket
      // File uploads still need HTTP multipart
      final message = {'type': 'send_message', 'content': content};

      _channel!.sink.add(jsonEncode(message));
      debugPrint('📤 Message sent: $content');
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      errorMessage = 'Failed to send message: $e';
      Future.microtask(() => notifyListeners());
    }
  }

  // Disconnect WebSocket
  void disconnect({bool notify = true}) {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      isConnected = false;
      hasNewMessage = false;
      debugPrint('🔴 WebSocket disconnected');

      // Only notify if requested and schedule for next frame
      if (notify) {
        Future.microtask(() => notifyListeners());
      }
    }
  }

  @override
  void dispose() {
    // Don't notify listeners during dispose
    disconnect(notify: false);
    super.dispose();
  }
}
