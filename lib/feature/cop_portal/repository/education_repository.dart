import 'dart:convert';
import 'dart:developer';
import 'package:denz_sen/core/http/authenticated_client.dart';
import '../../../core/base_url/base_url.dart';
import '../model/education_model.dart';

class EducationRepository {
  Future<EducationHomeResponse?> fetchEducationHome() async {
    final client = AuthenticatedClient();
    try {
      final uri = Uri.parse('$baseUrl/api/v1/education/home');

      log('Fetching education data from: $uri');

      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
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
