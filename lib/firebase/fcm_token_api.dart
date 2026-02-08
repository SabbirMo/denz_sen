import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:denz_sen/core/base_url/base_url.dart';

class FcmTokenApi {
  /// FCM Token backend এ save করুন
  static Future<bool> sendTokenToBackend(String fcmToken) async {
    try {
      print('📤 Sending FCM token to backend...');

      // User এর auth token get করুন
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('token') ?? '';

      if (authToken.isEmpty) {
        print('⚠️ No auth token found. User might not be logged in.');
        return false;
      }

      // Try PUT method first (most REST APIs use PUT for update/set operations)
      print('🔄 Attempting PUT method...');
      var response = await http.put(
        Uri.parse('$baseUrl/api/v1/users/me/device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcm_token': fcmToken, 'device_type': 'android'}),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      // If PUT fails with 405, try PATCH
      if (response.statusCode == 405) {
        print('⚠️ PUT not allowed, trying PATCH method...');
        response = await http.patch(
          Uri.parse('$baseUrl/api/v1/users/me/device-token'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({'fcm_token': fcmToken, 'device_type': 'android'}),
        );

        print('📡 PATCH Response status: ${response.statusCode}');
        print('📡 PATCH Response body: ${response.body}');
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        print('✅ FCM token successfully sent to backend');

        // Token sent flag save করুন
        await prefs.setBool('fcm_token_sent', true);
        await prefs.setString('last_sent_fcm_token', fcmToken);

        return true;
      } else {
        print('❌ Failed to send token. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending token to backend: $e');
      return false;
    }
  }

  /// Token update করুন (যদি নতুন token আসে)
  static Future<bool> updateToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSentToken = prefs.getString('last_sent_fcm_token') ?? '';

    // যদি token same হয় তাহলে আবার পাঠানোর দরকার নেই
    if (lastSentToken == newToken) {
      print('ℹ️ Token already up to date');
      return true;
    }

    return await sendTokenToBackend(newToken);
  }

  /// Check করুন token পাঠানো হয়েছে কিনা
  static Future<bool> isTokenSent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fcm_token_sent') ?? false;
  }

  /// Token delete করুন backend থেকে (Logout এর সময়)
  static Future<bool> deleteTokenFromBackend() async {
    try {
      print('🗑️ Deleting FCM token from backend...');

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('token') ?? '';

      if (authToken.isEmpty) {
        print('⚠️ No auth token found.');
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/users/me/device-token'),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ FCM token deleted from backend');

        // Local flags clear করুন
        await prefs.remove('fcm_token_sent');
        await prefs.remove('last_sent_fcm_token');

        return true;
      } else {
        print('❌ Failed to delete token. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting token: $e');
      return false;
    }
  }
}
