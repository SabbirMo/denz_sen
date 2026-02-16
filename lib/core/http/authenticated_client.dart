import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:denz_sen/core/refresh_token/refresh_token.dart';

class AuthenticatedClient {
  final RefreshTokenProvider _refreshTokenProvider = RefreshTokenProvider();
  bool _isRefreshing = false;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return _makeRequest(() async {
      final token = await _getAccessToken();
      return http.get(
        url,
        headers: {...?headers, 'Authorization': 'Bearer $token'},
      );
    });
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _makeRequest(() async {
      final token = await _getAccessToken();
      return http.post(
        url,
        headers: {...?headers, 'Authorization': 'Bearer $token'},
        body: body,
      );
    });
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _makeRequest(() async {
      final token = await _getAccessToken();
      return http.put(
        url,
        headers: {...?headers, 'Authorization': 'Bearer $token'},
        body: body,
      );
    });
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers}) async {
    return _makeRequest(() async {
      final token = await _getAccessToken();
      return http.delete(
        url,
        headers: {...?headers, 'Authorization': 'Bearer $token'},
      );
    });
  }

  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _makeRequest(() async {
      final token = await _getAccessToken();
      return http.patch(
        url,
        headers: {...?headers, 'Authorization': 'Bearer $token'},
        body: body,
      );
    });
  }

  /// For multipart requests (file uploads)
  Future<http.Response> multipart(
    String method,
    Uri url, {
    Map<String, String>? fields,
    Map<String, String>? headers,
    List<http.MultipartFile>? files,
  }) async {
    return _makeMultipartRequest(() async {
      final token = await _getAccessToken();
      final request = http.MultipartRequest(method, url);

      request.headers['Authorization'] = 'Bearer $token';
      if (headers != null) {
        request.headers.addAll(headers);
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    });
  }

  Future<http.Response> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    final response = await request();

    // If we get 401 Unauthorized, try to refresh the token
    if (response.statusCode == 401 && !_isRefreshing) {
      debugPrint('🔄 Access token expired, refreshing...');
      _isRefreshing = true;
      final refreshed = await _refreshTokenProvider.refreshAccessToken();
      _isRefreshing = false;

      if (refreshed) {
        debugPrint('✅ Token refreshed, retrying request...');
        // Retry the original request with new token
        return await request();
      } else {
        debugPrint('❌ Token refresh failed, user needs to login again');
      }
    }

    return response;
  }

  Future<http.Response> _makeMultipartRequest(
    Future<http.Response> Function() request,
  ) async {
    final response = await request();

    // If we get 401 Unauthorized, try to refresh the token
    if (response.statusCode == 401 && !_isRefreshing) {
      debugPrint('🔄 Access token expired, refreshing...');
      _isRefreshing = true;
      final refreshed = await _refreshTokenProvider.refreshAccessToken();
      _isRefreshing = false;

      if (refreshed) {
        debugPrint('✅ Token refreshed, retrying request...');
        // Retry the original request with new token
        return await request();
      } else {
        debugPrint('❌ Token refresh failed, user needs to login again');
      }
    }

    return response;
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
