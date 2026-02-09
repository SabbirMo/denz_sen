import 'dart:io';

import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/home/provider/profile_show_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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
        Consumer<ProfileShowProvider>(
          builder: (_, ref, _) {
            ImageProvider? imageProvider;
            bool hasValidImage = false;

            if (ref.profile?.avatarUrl != null &&
                ref.profile!.avatarUrl!.isNotEmpty) {
              if (ref.profile!.avatarUrl!.startsWith('http')) {
                imageProvider = NetworkImage(ref.profile!.avatarUrl!);
                hasValidImage = true;
              } else {
                try {
                  final file = File(
                    ref.profile!.avatarUrl!.replaceAll('file://', ''),
                  );
                  if (file.existsSync()) {
                    imageProvider = FileImage(file);
                    hasValidImage = true;
                  }
                } catch (e) {
                  // File doesn't exist or error occurred
                  hasValidImage = false;
                }
              }
            }

            return CircleAvatar(
              radius: 26.r,
              backgroundColor: AppColors.grey.withValues(alpha: 0.1),
              backgroundImage: hasValidImage ? imageProvider : null,
              child: !hasValidImage
                  ? Icon(
                      Icons.person,
                      size: 30.r,
                      color: AppColors.primaryColor,
                    )
                  : null,
            );
          },
        ),
        AppSpacing.w14,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello 👋', style: AppStyle.medium14),
            Text(userName, style: AppStyle.medium16),
          ],
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
