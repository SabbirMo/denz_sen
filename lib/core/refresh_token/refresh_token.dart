import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as _client;
import 'package:shared_preferences/shared_preferences.dart';

class RefreshTokenProvider {
  Future<bool> refreshAccessToken() async {
    debugPrint('🔍 Starting token refresh...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      debugPrint('🔍 Refresh token exists: ${refreshToken != null}');

      if (refreshToken == null) {
        debugPrint('⚠️ No refresh token found, cannot refresh access token');
        return false;
      }

      debugPrint('🌐 Making API call to: $baseUrl/api/v1/auth/refresh-token');
      debugPrint(
        '🔍 Refresh token (first 20 chars): ${refreshToken.substring(0, 20)}...',
      );
      debugPrint('⏱️ Setting 5 second timeout...');

      final response = await _client
          .post(
            Uri.parse('$baseUrl/api/v1/auth/refresh-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('⏱️ TIMEOUT: Token refresh timed out after 5 seconds');
              throw TimeoutException('Request timeout after 5 seconds');
            },
          );

      debugPrint('📡 Response received! Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('access_token', data['access_token']);
        debugPrint('✅ Access token refreshed successfully');

        if (data['refresh_token'] != null) {
          await prefs.setString('refresh_token', data['refresh_token']);
          debugPrint('✅ Refresh token updated');
        }

        return true;
      } else {
        debugPrint(
          '⚠️ Failed to refresh token, status code: ${response.statusCode}',
        );
        debugPrint('⚠️ Response: ${response.body}');

        // Only clear auth tokens, not all preferences
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        return false;
      }
    } on TimeoutException catch (e) {
      debugPrint('⏱️ TIMEOUT CAUGHT: $e - clearing tokens and showing login');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
      } catch (_) {}
      return false;
    } on SocketException catch (e) {
      debugPrint('🌐 NETWORK ERROR: $e - no internet connection');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
      } catch (_) {}
      return false;
    } catch (e, stackTrace) {
      debugPrint('⚠️ ERROR refreshing token: $e');
      debugPrint('⚠️ Stack trace: $stackTrace');

      // Clear tokens on any error
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
      } catch (_) {}

      return false;
    }
  }
}
