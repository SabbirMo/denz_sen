import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SigninProvider extends ChangeNotifier {
  bool isPassword = true;

  // Reusable HTTP client for faster connections
  final http.Client _client = http.Client();

  // Cache SharedPreferences instance
  SharedPreferences? _prefs;

  void togglePasswordVisibility() {
    isPassword = !isPassword;
    notifyListeners();
  }

  void resetVisibility() {
    isPassword = true;
    notifyListeners();
  }

  //signin API integration will be here

  bool isLoading = false;
  String? errorMessage;

  Future<bool> signin(String email, String password) async {
    debugPrint('========================================');
    debugPrint('🔐 STARTING LOGIN PROCESS');
    debugPrint('========================================');
    debugPrint('📧 Email: $email');
    debugPrint('🔑 Password Length: ${password.length} characters');
    debugPrint('⏰ Timestamp: ${DateTime.now()}');

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    debugPrint('✅ Loading state set to true');

    // Initialize SharedPreferences early for parallel processing
    debugPrint('📦 Initializing SharedPreferences...');
    final stopwatch = Stopwatch()..start();
    _prefs ??= await SharedPreferences.getInstance();

    final uri = Uri.parse('$baseUrl/api/v1/auth/login');
    debugPrint('🌐 API Endpoint: $uri');

    try {
      final requestBody = {'email': email, 'password': password};

      stopwatch.reset();
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Login request timed out after 30 seconds. Please check your connection and try again.',
              );
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ SUCCESS: Login API returned ${response.statusCode}');

        final data = jsonDecode(response.body);
        debugPrint('📄 Parsed Response Data: $data');

        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        //final userData = data['user'];
        final role = data['user']['role'] ?? '';
        debugPrint('👤 User Role: $role');

        // Store tokens and user data in parallel for faster processing
        stopwatch.reset();
        await Future.wait([
          _prefs!.setString('access_token', accessToken),
          _prefs!.setString('refresh_token', refreshToken),
          _prefs!.setString('role', role),
        ]);

        // Verify tokens were saved
        final savedAccessToken = _prefs!.getString('access_token');
        final savedRefreshToken = _prefs!.getString('refresh_token');
        final savedRole = _prefs!.getString('role');
        debugPrint(
          '✅ Verified Access Token Saved: ${savedAccessToken != null}',
        );
        debugPrint(
          '✅ Verified Refresh Token Saved: ${savedRefreshToken != null}',
        );
        debugPrint('✅ Verified Role Saved: ${savedRole != null}');
        debugPrint('🎉 Signin Successful!');
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('FAILURE: Login API returned ${response.statusCode}');
        final data = jsonDecode(response.body);
        debugPrint('📄 Error Response Data: $data');

        if (data['detail'] != null) {
          if (data['detail'] is String) {
            errorMessage = data['detail'];
            debugPrint(' Error Message (String): $errorMessage');
          } else if (data['detail'] is List) {
            final details = data['detail'] as List;
            errorMessage = details.isNotEmpty
                ? details[0]
                : 'An unknown error occurred.';
            debugPrint('❌ Error Message (List): $errorMessage');
            debugPrint('❌ Full Details List: $details');
          } else {
            errorMessage = 'An unknown error occurred.';
            debugPrint('❌ Error Message (Unknown): $errorMessage');
          }
        } else {
          errorMessage = 'An unknown error occurred.';
          debugPrint('❌ Error Message (No Detail): $errorMessage');
        }

        debugPrint('========================================');
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Exception Type: ${e.runtimeType}');
      debugPrint('Exception Message: $e');
      debugPrint('Stack Trace: ${StackTrace.current}');

      errorMessage = e.toString().contains('timed out')
          ? 'Login timed out. Please try again.'
          : 'Failed to connect. Please check your internet connection.';

      debugPrint('========================================');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> logout() async {
    debugPrint('========== Starting Logout ==========');
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all stored user data
      await prefs.remove('email');
      await prefs.remove('full_name');
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');

      // Or clear everything
      // await prefs.clear();

      debugPrint('All user data cleared from SharedPreferences');
      debugPrint('========== Logout Successful ==========');

      notifyListeners();
    } catch (e) {
      debugPrint('Logout Error: $e');
    }
  }
}
