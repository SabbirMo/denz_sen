import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.icon,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
  });

  final String buttonText;
  final Function()? onPressed;
  final IconData? icon;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding: EdgeInsets.all(12),
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primaryColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: AppStyle.book16.copyWith(
                color: textColor ?? AppColors.white,
              ),
            ),
            AppSpacing.w10,
            if (icon != null) Icon(icon, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
