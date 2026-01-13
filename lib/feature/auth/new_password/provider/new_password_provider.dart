import 'package:flutter/material.dart';

class NewPasswordProvider extends ChangeNotifier {
  bool newPassword = true;
  bool newConfirmPassword = true;

  void toggleNewPasswordVisibility() {
    newPassword = !newPassword;
    notifyListeners();
  }
  void toggleNewConfirmPasswordVisibility() {
    newConfirmPassword = !newConfirmPassword;
    notifyListeners();
  }

  void resetVisibility() {
    newPassword = true;
    newConfirmPassword = true;
    notifyListeners();
  }

}