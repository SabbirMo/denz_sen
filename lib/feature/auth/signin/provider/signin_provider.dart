import 'package:flutter/material.dart';

class SigninProvider extends ChangeNotifier {
  bool isPassword = true;

  void togglePasswordVisibility() {
    isPassword = !isPassword;
    notifyListeners();
  }

  void resetVisibility() {
    isPassword = true;
    notifyListeners();
  }
}
