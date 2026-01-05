import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onTap,
    required this.title,
    this.shadow = true,
    this.backgroundColor,
    this.height,
    this.width,
    this.horizontalPadding,
    this.verticalPadding,
    this.isLoading = false,
  });

  final Function()? onTap;
  final String title;
  final bool shadow;
  final Color? backgroundColor;

  final double? width;
  final double? height;

  final double? horizontalPadding;
  final double? verticalPadding;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: height ?? 48.h,
        width: width,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? 16.w,
          vertical: verticalPadding ?? 10.h,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primaryColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppStyle.medium16.copyWith(color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
