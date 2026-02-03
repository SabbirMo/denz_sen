import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/feature/my_cases/model/my_cases_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyCasesProvider extends ChangeNotifier {
  bool isLoadingActive = false;
  bool isLoadingClosed = false;
  bool isLoadingPending = false;
  String? errorMessageActive;
  String? errorMessageClosed;
  String? errorMessagePending;

  List<MyCasesModel> activeCases = [];
  List<MyCasesModel> closedCases = [];
  List<MyCasesModel> pendingCases = [];

  Future<List<MyCasesModel>> fetchMyCases({required String status}) async {
    // Set loading state based on status
    if (status == 'Active') {
      isLoadingActive = true;
      errorMessageActive = null;
    } else if (status == 'Closed') {
      isLoadingClosed = true;
      errorMessageClosed = null;
    } else if (status == 'Pending') {
      isLoadingPending = true;
      errorMessagePending = null;
    }
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final uri = Uri.parse('$baseUrl/api/v1/cases/?status=$status');
      debugPrint('Fetching cases with status: $status');
      debugPrint('API URL: $uri');

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        debugPrint('Fetched $status cases: ${data.length} items');
        final cases = data
            .map((caseJson) => MyCasesModel.fromJson(caseJson))
            .toList();

        // Store in appropriate list based on status
        if (status == 'Active') {
          activeCases = cases;
          isLoadingActive = false;
        } else if (status == 'Closed') {
          closedCases = cases;
          isLoadingClosed = false;
        } else if (status == 'Pending') {
          pendingCases = cases;
          isLoadingPending = false;
        }

        notifyListeners();
        return cases;
      } else {
        final errorMsg = 'Failed to fetch cases. Please try again.';
        if (status == 'Active') {
          errorMessageActive = errorMsg;
          isLoadingActive = false;
        } else if (status == 'Closed') {
          errorMessageClosed = errorMsg;
          isLoadingClosed = false;
        } else if (status == 'Pending') {
          errorMessagePending = errorMsg;
          isLoadingPending = false;
        }

        debugPrint(
          'ERROR: Fetching cases failed with status ${response.statusCode}',
        );
        debugPrint('Response body: ${response.body}');
        notifyListeners();
        return [];
      }
    } catch (e) {
      final errorMsg = 'Failed to fetch cases. Please try again.';
      if (status == 'Active') {
        errorMessageActive = errorMsg;
        isLoadingActive = false;
      } else if (status == 'Closed') {
        errorMessageClosed = errorMsg;
        isLoadingClosed = false;
      } else if (status == 'Pending') {
        errorMessagePending = errorMsg;
        isLoadingPending = false;
      }

      debugPrint('ERROR: Exception while fetching cases: $e');
      notifyListeners();
      return [];
    }
  }
}
