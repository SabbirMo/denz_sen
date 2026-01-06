import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DispatchAlertBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            AppSpacing.h10,
            Text(
              'New Dispatch',
              style: AppStyle.semiBook18.copyWith(
                fontSize: 20.sp,
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.h4,
            Divider(color: AppColors.border, thickness: 1.h),
            AppSpacing.h6,
            Text('Case # 00020', style: AppStyle.semiBook16),
            AppSpacing.h10,
            const CaseRowWidget(slotsText: 'Slots', slotsValue: '0/3'),
            const CaseRowWidget(slotsText: 'Date', slotsValue: '07.08.2025'),
            const CaseRowWidget(
              slotsText: 'Address',
              slotsValue: '4719 SE 6th Ave.',
            ),
            const CaseRowWidget(slotsText: 'City', slotsValue: 'Cape Coral'),
            const CaseRowWidget(slotsText: 'State', slotsValue: 'Florida'),
            const CaseRowWidget(slotsText: 'Zip Code', slotsValue: '33904'),
            AppSpacing.h8,
            Text(
              'Details',
              style: AppStyle.semiBook18.copyWith(
                fontSize: 20.sp,
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Cars4Sale is a commercial property whose address received 12 UACS per ORR records. Please observe the location and report back to the case manager.',
              style: AppStyle.book14,
            ),
            AppSpacing.h4,
            Divider(color: AppColors.border, thickness: 1.h),
            AppSpacing.h6,
            Align(
              alignment: Alignment.center,
              child: Text(
                'Do you wisht to accept this assignment?',
                style: AppStyle.semiBook14.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            AppSpacing.h10,
            GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 3.5,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                CustomButton(
                  buttonText: ('Yes'),
                  backgroundColor: AppColors.green,
                  onPressed: () {},
                ),
                CustomButton(
                  buttonText: ('No'),
                  backgroundColor: AppColors.red,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CaseRowWidget extends StatelessWidget {
  const CaseRowWidget({
    super.key,
    required this.slotsText,
    required this.slotsValue,
  });

  final String slotsText;
  final String slotsValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(slotsText, style: AppStyle.medium14),
          Text(
            slotsValue,
            style: AppStyle.semiBook14.copyWith(color: AppColors.black),
          ),
        ],
      ),
    );
  }
}
