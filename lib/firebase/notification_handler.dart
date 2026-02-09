import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/feature/home/widget/dispatch_alert_bottom_sheet.dart';
import 'package:denz_sen/firebase/provider/new_dispathc_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Handles notification UI display
class NotificationHandler {
  /// Show custom dispatch alert dialog
  static void showDispatchAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      builder: (context) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 58.h),
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/alertIcon.png'),
                    AppSpacing.h12,
                    Text(
                      'Dispatch Alert!',
                      style: AppStyle.semiBook16.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.h12,
                    Text(
                      'A dispatch in your area has been activated',
                      style: AppStyle.medium14.copyWith(color: AppColors.white),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.h12,
                    CustomButton(
                      buttonText: 'See Details',
                      onPressed: () async {
                        // Save the navigator context before popping
                        final navigatorContext = Navigator.of(context).context;

                        // Get the provider before closing dialog
                        final provider =
                            Provider.of<NewDispathcDetailsProvider>(
                              context,
                              listen: false,
                            );

                        // Close the alert dialog first
                        Navigator.of(context).pop();

                        // Check if widget is still mounted
                        if (!navigatorContext.mounted) return;

                        // Show loading dialog
                        showDialog(
                          context: navigatorContext,
                          barrierDismissible: false,
                          builder: (dialogContext) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        // Fetch dispatch details
                        final success = await provider.fetchDispatchDetails();

                        // Check if still mounted and close loading dialog
                        if (navigatorContext.mounted) {
                          Navigator.of(
                            navigatorContext,
                            rootNavigator: true,
                          ).pop();
                        }

                        // Small delay to ensure dialog is closed
                        await Future.delayed(const Duration(milliseconds: 100));

                        // Check if still mounted before showing bottom sheet
                        if (!navigatorContext.mounted) return;

                        // Show bottom sheet with data or error
                        if (success) {
                          DispatchAlertBottomSheet.show(navigatorContext);
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(navigatorContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.errorMessage ??
                                    'Failed to load dispatch details',
                              ),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        }
                      },
                      width: double.infinity,
                      backgroundColor: AppColors.white,
                      textColor: AppColors.red,
                    ),
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
