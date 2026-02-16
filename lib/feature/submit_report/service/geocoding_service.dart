import 'dart:convert';
import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';

class GeocodingService {
  final AuthenticatedClient _client = AuthenticatedClient();

  Future<Map<String, dynamic>?> getAddressFromLatLng(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/v1/reports/reverse-geocode?latitude=$latitude&longitude=$longitude',
      );

      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract address details from response
        return {
          'address': data['address'] ?? '',
          'city': data['city'] ?? '',
          'state': data['state'] ?? '',
          'zipCode': data['zip_code'] ?? '',
        };
      } else {
        print('Geocoding API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching address from coordinates: $e');
      return null;
    }
  }
}
