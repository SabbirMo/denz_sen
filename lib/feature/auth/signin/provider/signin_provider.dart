import 'dart:convert';
import 'dart:developer';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/firebase/firebase_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SigninProvider extends ChangeNotifier {
  bool isPassword = true;
  bool isLoading = false;
  String? errorMessage;

  final http.Client _client = http.Client();
  SharedPreferences? _prefs;

  void togglePasswordVisibility() {
    isPassword = !isPassword;
    notifyListeners();
  }

  void resetVisibility() {
    isPassword = true;
    notifyListeners();
  }

  /// =========================
  /// LOGIN FUNCTION
  /// =========================
  Future<bool> signin(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _prefs ??= await SharedPreferences.getInstance();
    final uri = Uri.parse('$baseUrl/api/v1/auth/login');

    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        final role = data['user']['role'] ?? '';

        log("Access Token: $accessToken", name: 'Login');
        log("Refresh Token: $refreshToken", name: 'Login');
        log("User Role: $role", name: 'Login');

        // Save tokens & role
        await Future.wait([
          _prefs!.setString('access_token', accessToken),
          _prefs!.setString('refresh_token', refreshToken),
          _prefs!.setString('role', role),
        ]);

        // Send FCM token to backend
        try {
          await FirebaseNotificationService.sendSavedTokenToBackend();
        } catch (e) {
          debugPrint('⚠️ FCM token sending error: $e');
        }

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        errorMessage = data['detail'] ?? 'Login failed';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Failed to connect. Check your internet.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //   /// =========================
  //   /// REFRESH TOKEN FUNCTION
  //   /// =========================
  //   Future<bool> refreshAccessToken() async {
  //     final prefs = await SharedPreferences.getInstance();
  //     final refreshToken = prefs.getString('refresh_token');
  //     if (refreshToken == null) return false;

  //     try {
  //       final response = await _client.post(
  //         Uri.parse('$baseUrl/api/v1/auth/refresh-token'),
  //         headers: {
  //           'Authorization': 'Bearer $refreshToken',
  //           'Content-Type': 'application/json',
  //         },
  //         body: jsonEncode({'refresh_token': refreshToken}),
  //       );

  //       if (response.statusCode == 200) {
  //         final data = jsonDecode(response.body);
  //         await prefs.setString('access_token', data['access_token']);
  //         if (data['refresh_token'] != null) {
  //           await prefs.setString('refresh_token', data['refresh_token']);
  //         }
  //         debugPrint('✅ Access token refreshed successfully');
  //         return true;
  //       } else {
  //         await prefs.clear(); // refresh token invalid → logout
  //         return false;
  //       }
  //     } catch (e) {
  //       debugPrint('⚠️ Error refreshing token: $e');
  //       return false;
  //     }
  //   }

  //   Future<http.Response> getWithAuth(String url) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   var token = prefs.getString('access_token');

  //   final response = await _client.get(
  //     Uri.parse(url),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (response.statusCode == 401) {
  //     // Token expired → try refresh
  //     final refreshed = await refreshAccessToken();
  //     if (refreshed) {
  //       token = prefs.getString('access_token');
  //       return _client.get(
  //         Uri.parse(url),
  //         headers: {'Authorization': 'Bearer $token'},
  //       );
  //     }
  //   }

  //   return response;
  // }

  /// =========================
  /// LOGOUT FUNCTION
  /// =========================
  Future<void> logout() async {
    try {
      await FirebaseNotificationService.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      notifyListeners();
      debugPrint('✅ Logout successful, all data cleared');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
    }
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
