import 'package:flutter/material.dart';

class ChangePasswordProvider extends ChangeNotifier {
  bool currentPassword = true;
  bool newPassword = true;
  bool confirmNewPassword = true;

  void toggleCurrentPasswordVisibility() {
    currentPassword = !currentPassword;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    newPassword = !newPassword;
    notifyListeners();
  }

  void toggleConfirmNewPasswordVisibility() {
    confirmNewPassword = !confirmNewPassword;
    notifyListeners();
  }

  void resetVisibility() {
    currentPassword = true;
    newPassword = true;
    confirmNewPassword = true;
    notifyListeners();
  }

} 