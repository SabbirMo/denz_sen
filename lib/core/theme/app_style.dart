import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppStyle {
  AppStyle._();
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.white,
    primaryColor: AppColors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
    ),
  );

  static final boldText = TextStyle(
    fontSize: 20.sp,
    fontFamily: 'Copperplate',
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    height: 1.5,
    letterSpacing: 1.7,
  );
  static final book16 = TextStyle(
    fontSize: 16.sp,
    fontFamily: 'CooperHewittBook',
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static final book14 = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'CooperHewittBook',
    fontWeight: FontWeight.w400,
    color: AppColors.greyText,
  );

  static final semiBook30 = TextStyle(
    fontSize: 30.sp,
    fontFamily: 'CooperHewittBookSemiBold',
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static final semiBook18 = TextStyle(
    fontSize: 18.sp,
    fontFamily: 'CooperHewittBookSemiBold',
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  static final semiBook20 = TextStyle(
    fontSize: 20.sp,
    fontFamily: 'CooperHewittBookSemiBold',
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static final semiBook16 = TextStyle(
    fontSize: 16.sp,
    fontFamily: 'CooperHewittBookSemiBold',
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  static final semiBook14 = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'CooperHewittBookSemiBold',
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static final medium16 = TextStyle(
    fontSize: 16.sp,
    fontFamily: 'CooperHewittBookMedium',
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  static final medium14 = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'CooperHewittBookMedium',
    fontWeight: FontWeight.bold,
    color: AppColors.greyText,
  );
  static final medium12 = TextStyle(
    fontSize: 12.sp,
    fontFamily: 'CooperHewittBookMedium',
    fontWeight: FontWeight.bold,
    color: AppColors.greyText,
  );
}
