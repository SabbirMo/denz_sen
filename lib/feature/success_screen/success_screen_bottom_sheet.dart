import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/feature/auth/signin/screen/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

enum SuccessType { passwordChanged, reportSubmitted, verify }

class SuccessScreenBottomSheet {
  static void show(
    BuildContext context, {
    SuccessType type = SuccessType.passwordChanged,
  }) {
    final bool isReportSubmitted = type == SuccessType.reportSubmitted;
    final bool isVerify = type == SuccessType.verify;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
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
                AppSpacing.h16,

                if (isReportSubmitted == false && isVerify == false)
                  Text(
                    'Your password has been changed successfully!',
                    style: AppStyle.book14,
                  ),

                AppSpacing.h18,

                RepaintBoundary(
                  child: LottieBuilder.asset('assets/lottie/tick_green.json'),
                ),

                AppSpacing.h10,

                if (isReportSubmitted == true) ...[
                  Text('Report Submitted', style: AppStyle.semiBook20),
                  AppSpacing.h4,
                  Text(
                    'Your tip was submitted successfully.',
                    style: AppStyle.book14,
                  ),
                ] else
                  ...[],
                if (isVerify == true) ...[
                  Text('Verification Successful', style: AppStyle.semiBook20),
                  AppSpacing.h4,
                  Text(
                    'Your email has been verified successfully.',
                    style: AppStyle.book14,
                  ),
                ] else
                  ...[],
                AppSpacing.h20,
                CustomButton(
                  buttonText: isReportSubmitted ? "Okay" : "Return to Login",
                  onPressed: () {
                    if (isReportSubmitted) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    }
                  },
                ),
                AppSpacing.h26,
              ],
            ),
          ),
        );
      },
    );
  }
}
