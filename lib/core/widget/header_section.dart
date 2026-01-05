import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/mainPic.png',
          fit: BoxFit.cover,
          height: 260.h,
          width: double.infinity,
        ),
        Container(
          width: double.infinity,
          height: 260.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.white.withValues(alpha: 0.3), AppColors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        SizedBox(
          height: 260.h, // image area
          child: Center(
            child: Container(
              width: 60.w,
              height: 60.h,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Image.asset(
                'assets/icons/mainIcon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(text ?? '', style: AppStyle.semiBook30),
              Text(
                'Stay informed. Respond faster. Collaborate \nsmarter.',
                style: AppStyle.book16.copyWith(color: AppColors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
