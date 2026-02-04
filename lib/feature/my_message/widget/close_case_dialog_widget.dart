import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CloseCaseDialog {
  static Future<void> show(BuildContext context, {VoidCallback? onConfirm}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          backgroundColor: AppColors.white,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are You sure to Close the case ?',
                  style: TextStyle(fontSize: 15.sp),
                ),
                SizedBox(height: 22.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: 'No',
                        backgroundColor: AppColors.border,
                        textColor: AppColors.black,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomButton(
                        buttonText: 'Yes',
                        onPressed: () {
                          Navigator.pop(context);

                          if (onConfirm != null) {
                            onConfirm();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Case closed successfully'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
