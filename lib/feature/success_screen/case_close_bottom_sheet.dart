import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CaseCloseBottomSheet {
  static void show(BuildContext context) {
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

                Image(
                  image: AssetImage('assets/images/clap.png'),
                  width: 100.w,
                  height: 100.h,
                ),

                AppSpacing.h10,
                Text('Case Closed', style: AppStyle.semiBook20),
                AppSpacing.h8,
                Text(
                  '+20 Points',
                  style: AppStyle.semiBook16.copyWith(color: AppColors.green),
                ),
                AppSpacing.h8,
                Text(
                  'Case #00009 was solved and marked as closed. Great work!',
                  style: AppStyle.book14,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.h20,
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: "See Details",
                        backgroundColor: AppColors.border,
                        textColor: AppColors.black,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomButton(
                        buttonText: "Okay",
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
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
