import 'dart:convert';

import 'package:denz_sen/core/base_url/base_url.dart';
import 'package:denz_sen/core/http/authenticated_client.dart';
import 'package:denz_sen/feature/my_message/model/add_member_model.dart';
import 'package:flutter/material.dart';

class AddMemberProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<AddMemberModel> userList = [];

  Future<void> searchUsers({String query = '', required int caseId}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final client = AuthenticatedClient();

    try {
      final queryParams = <String, String>{'case_id': caseId.toString()};
      if (query.isNotEmpty) {
        queryParams['query'] = query;
      }

      final uri = Uri.parse(
        '$baseUrl/api/v1/users/search',
      ).replace(queryParameters: queryParams);
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        userList = jsonData
            .map((json) => AddMemberModel.fromJson(json))
            .toList();
        errorMessage = null;
      } else {
        errorMessage = 'Failed to load users: ${response.statusCode}';
        userList = [];
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      userList = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMember({required int caseId, required int userId}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    final client = AuthenticatedClient();

    try {
      final uri = Uri.parse('$baseUrl/api/v1/cases/$caseId/members');
      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final user = userList.firstWhere((u) => u.id == userId);
          print('User Added: ${user.fullName}');
        } catch (e) {
          print('User added, but could not find name in local list.');
        }

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Failed to add member: ${response.statusCode}';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
