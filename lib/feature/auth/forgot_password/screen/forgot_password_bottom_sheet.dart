import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/core/widget/custom_filed.dart';
import 'package:denz_sen/feature/auth/forgot_password/provider/forgot_password_provider.dart';
import 'package:denz_sen/feature/verification/verification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ForgotPasswordBottomSheet {
  static void show(BuildContext context) {
    final emailController = TextEditingController();
    Provider.of<ForgotPasswordProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
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
                      BottomSheetIconText(title: 'Forgot Password?'),
                      AppSpacing.h16,
                      Text(
                        'Forgotten your password? No worries, just enter your email to receive password reset instructions',
                        style: AppStyle.book14,
                      ),
                      AppSpacing.h12,
                      CustomField(
                        title: 'Email Address',
                        hintText: 'Enter your email',
                        controller: emailController,
                      ),
                      AppSpacing.h12,
                      Consumer<ForgotPasswordProvider>(
                        builder: (context, provider, _) {
                          return CustomButton(
                            isLoading: provider.isLoading,
                            onPressed: () async {
                              final email = emailController.text.trim();

                              final success = await provider
                                  .sendForgotPasswordEmail(email);
                              if (success) {
                                Navigator.pop(
                                  context,
                                ); // Close current bottom sheet first
                                VerificationPage.show(
                                  context,
                                  otpSource: OtpSource.passwordReset,
                                );
                              }
                            },
                            buttonText: 'Send Email',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
