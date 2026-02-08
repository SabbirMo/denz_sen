import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RankBadgeWidget extends StatelessWidget {
  final String iconPath;
  final bool isUnlocked;
  final double size;
  final String? label;

  const RankBadgeWidget({
    super.key,
    required this.iconPath,
    this.isUnlocked = true,
    this.size = 60,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: isUnlocked ? 1.0 : 0.3,
          child: Container(
            width: size.w,
            height: size.w,
            decoration: const BoxDecoration(
              // You can add a hexagonal shape decoration here if you have a custom clipper or image
            ),
            child: Image.asset(iconPath, fit: BoxFit.contain),
          ),
        ),
        if (label != null) ...[
          SizedBox(height: 4.h),
          Text(
            label!,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
