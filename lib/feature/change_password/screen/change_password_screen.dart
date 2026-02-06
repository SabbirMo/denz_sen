import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/core/widget/custom_filed.dart';
import 'package:denz_sen/feature/change_password/provider/change_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  bool _isFirstBuild = true;

  @override
  void dispose() {
    super.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<ChangePasswordProvider>(
          context,
          listen: false,
        );
        provider.resetVisibility();
      });
      _isFirstBuild = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChangePasswordProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Text('Change Password', style: AppStyle.semiBook16),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              children: [
                CustomField(
                  title: 'Current Password',
                  hintText: 'Enter current password',
                  controller: currentPasswordController,
                  type: TextInputType.visiblePassword,
                  obsecureText: provider.currentPassword,
                  suffixIcon: IconButton(
                    onPressed: provider.toggleCurrentPasswordVisibility,
                    icon: Icon(
                      provider.currentPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                CustomField(
                  title: 'New Password',
                  hintText: 'Enter new password',
                  controller: newPasswordController,
                  type: TextInputType.visiblePassword,
                  obsecureText: provider.newPassword,
                  suffixIcon: IconButton(
                    onPressed: provider.toggleNewPasswordVisibility,
                    icon: Icon(
                      provider.newPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                CustomField(
                  title: 'Confirm New Password',
                  hintText: 'Confirm new password',
                  controller: confirmNewPasswordController,
                  type: TextInputType.visiblePassword,
                  obsecureText: provider.confirmNewPassword,
                  suffixIcon: IconButton(
                    onPressed: provider.toggleConfirmNewPasswordVisibility,
                    icon: Icon(
                      provider.confirmNewPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                AppSpacing.h20,
                CustomButton(
                  buttonText: 'Change Password',
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          // Validation
                          if (currentPasswordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter current password'),
                              ),
                            );
                            return;
                          }
                          if (newPasswordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter new password'),
                              ),
                            );
                            return;
                          }
                          if (confirmNewPasswordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please confirm new password'),
                              ),
                            );
                            return;
                          }
                          if (newPasswordController.text !=
                              confirmNewPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'New password and confirm password do not match',
                                ),
                              ),
                            );
                            return;
                          }

                          // Call API
                          await provider.changePassword(
                            currentPasswordController.text,
                            newPasswordController.text,
                            confirmNewPasswordController.text,
                          );

                          // Show result
                          if (provider.isSuccess == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Password changed successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Clear fields
                            currentPasswordController.clear();
                            newPasswordController.clear();
                            confirmNewPasswordController.clear();
                            // Navigate back
                            Navigator.pop(context);
                          } else if (provider.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.errorMessage!),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
