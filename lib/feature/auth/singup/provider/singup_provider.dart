import 'package:flutter/material.dart';

class SingupProvider extends ChangeNotifier{
  bool isPassword = true;
  bool isConfirmPassword = true;

  void togglePasswordVisibility() {
    isPassword = !isPassword;
    notifyListeners();
  }
  void toggleConfirmPasswordVisibility() {
    isConfirmPassword = !isConfirmPassword;
    notifyListeners();
  }

  void resetVisibility() {
    isPassword = true;
    isConfirmPassword = true;
    notifyListeners();
  }
}