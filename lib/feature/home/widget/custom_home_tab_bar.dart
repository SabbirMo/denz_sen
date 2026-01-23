import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/feature/home/widget/dispatch_alert_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomHomeAppBar extends StatelessWidget {
  const CustomHomeAppBar({
    super.key,
    this.userName = 'Jack Tyler',
    this.profileImagePath = 'assets/images/profile.png',
    this.onLeaderboardTap,
    this.onSettingsTap,
  });

  final String userName;
  final String profileImagePath;
  final VoidCallback? onLeaderboardTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26.r,
          backgroundImage: AssetImage(profileImagePath),
        ),
        AppSpacing.w14,
        GestureDetector(
          onTap: () {
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
                              style: AppStyle.medium14.copyWith(
                                color: AppColors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            AppSpacing.h12,
                            CustomButton(
                              buttonText: 'See Details',
                              onPressed: () {
                                Navigator.of(context).pop();
                                DispatchAlertBottomSheet.show(context);
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
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello 👋', style: AppStyle.medium14),
              Text(userName, style: AppStyle.medium16),
            ],
          ),
        ),
        const Spacer(),
        Row(
          children: [
            _circleIcon(Icons.leaderboard_outlined, onLeaderboardTap),
            AppSpacing.w10,
            _circleIcon(Icons.settings_outlined, onSettingsTap),
          ],
        ),
      ],
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24.w),
      ),
    );
  }
}
