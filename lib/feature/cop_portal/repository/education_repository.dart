import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/base_url/base_url.dart';
import '../model/education_model.dart';

class EducationRepository {
  Future<EducationHomeResponse?> fetchEducationHome() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');
      final uri = Uri.parse('$baseUrl/api/v1/education/home');

      log('Fetching education data from: $uri');
      log('Access Token: ${accessToken != null ? 'Present' : 'Missing'}');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      log('Response Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return EducationHomeResponse.fromJson(data);
      } else {
        log('Failed to load education data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching education data: $e');
      return null;
    }
  }
}
