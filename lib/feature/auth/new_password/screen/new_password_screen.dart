import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/core/widget/custom_filed.dart';
import 'package:denz_sen/feature/auth/new_password/provider/new_password_provider.dart';
import 'package:denz_sen/feature/success_screen/success_screen_bottom_sheet.dart';
import 'package:denz_sen/feature/verification/verification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class NewPasswordScreen {
  static void show(BuildContext context) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    Provider.of<NewPasswordProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 60.w,
                        height: 6.h,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.grey.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                    ),
                    BottomSheetIconText(title: 'Enter New password'),
                    AppSpacing.h12,
                    Text(
                      'Your OTP has been verified, please enter new password.',
                      style: AppStyle.book14.copyWith(fontSize: 13.sp),
                    ),
                    AppSpacing.h12,

                    // ✅ Use Consumer to get provider
                    Consumer<NewPasswordProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            CustomField(
                              controller: newPasswordController,
                              title: 'New Password',
                              hintText: 'Enter new password',
                              suffixIcon: IconButton(
                                onPressed: provider.toggleNewPasswordVisibility,
                                icon: provider.newPassword
                                    ? Icon(Icons.visibility_off_outlined)
                                    : Icon(Icons.visibility_outlined),
                              ),
                              obsecureText: provider.newPassword,
                            ),
                            CustomField(
                              controller: confirmPasswordController,
                              title: 'Confirm Password',
                              hintText: 'Enter confirm password',
                              suffixIcon: IconButton(
                                onPressed:
                                    provider.toggleNewConfirmPasswordVisibility,
                                icon: provider.newConfirmPassword
                                    ? Icon(Icons.visibility_off_outlined)
                                    : Icon(Icons.visibility_outlined),
                              ),
                              obsecureText: provider.newConfirmPassword,
                            ),
                          ],
                        );
                      },
                    ),

                    AppSpacing.h12,
                    Consumer<NewPasswordProvider>(
                      builder: (context, provider, _) => CustomButton(
                        buttonText: 'Change Password',
                        isLoading: provider.isLoading,
                        onPressed: () async {
                          debugPrint('🔘 Change Password button clicked');
                          final newPassword = newPasswordController.text.trim();
                          final confirmPassword = confirmPasswordController.text
                              .trim();

                          if (newPassword.isEmpty || confirmPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill in all fields'),
                              ),
                            );
                            return;
                          }

                          if (newPassword.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Password must be at least 8 characters',
                                ),
                              ),
                            );

                            return;
                          }

                          if (newPassword != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Passwords do not match')),
                            );
                            return;
                          }

                          // Call the API
                          debugPrint('🔄 Calling setNewPassword API...');
                          final success = await provider.setNewPassword(
                            newPassword,
                            confirmPassword,
                          );
                          debugPrint(
                            '📊 API call completed. Success: $success',
                          );

                          if (!context.mounted) return;

                          if (success) {
                            // Close current bottom sheet
                            Navigator.pop(context);

                            // Show success bottom sheet
                            SuccessScreenBottomSheet.show(
                              context,
                              type: SuccessType.passwordChanged,
                            );
                          } else {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.errorMessage ??
                                      'Failed to change password',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    AppSpacing.h26,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
