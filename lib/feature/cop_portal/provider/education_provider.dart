import 'package:flutter/material.dart';
import '../model/education_model.dart';
import '../repository/education_repository.dart';
import 'dart:developer';

class EducationProvider extends ChangeNotifier {
  final EducationRepository _repository = EducationRepository();
  EducationHomeResponse? _educationData;
  bool _isLoading = false;

  EducationHomeResponse? get educationData => _educationData;
  bool get isLoading => _isLoading;

  Future<void> getEducationHomeData() async {
    log('EducationProvider: Fetching education data...');
    _isLoading = true;
    notifyListeners();

    _educationData = await _repository.fetchEducationHome();

    if (_educationData != null) {
      log(
        'EducationProvider: Data fetched successfully. Videos: ${_educationData!.videos.length}, Guides: ${_educationData!.guides.length}',
      );
    } else {
      log('EducationProvider: Failed to fetch data or data is null.');
    }

    _isLoading = false;
    notifyListeners();
  }
}
