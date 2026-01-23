import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/feature/home/widget/dispatch_alert_bottom_sheet.dart';
import 'package:denz_sen/feature/my_cases/widget/case_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CloseCaseScreen extends StatefulWidget {
  const CloseCaseScreen({super.key});

  @override
  State<CloseCaseScreen> createState() => _CloseCaseScreenState();
}

class _CloseCaseScreenState extends State<CloseCaseScreen> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Color(0xfff9f6f7),
                border: Border.all(color: AppColors.lightGrey),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          'Case #12345',
                          style: AppStyle.medium14.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        CaseStatesWidget(status: Status.closed),
                        SizedBox(width: 8.w),
                        Icon(
                          isExpanded == true
                              ? Icons.keyboard_arrow_up_outlined
                              : Icons.keyboard_arrow_down_outlined,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Cape Coral, FL   ',
                          style: AppStyle.medium12,
                        ),

                        TextSpan(
                          text: '. 07.01.2025',
                          style: AppStyle.medium12.copyWith(
                            color: AppColors.lightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 200),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(thickness: 1.h, color: AppColors.border),
                        CaseRowWidget(
                          slotsText: 'Addres',
                          slotsValue: '1234 Main St.',
                        ),
                        CaseRowWidget(
                          slotsText: 'Zip Code',
                          slotsValue: '33993.',
                        ),
                        AppSpacing.h10,
                        Text(
                          'Event Detail',
                          style: AppStyle.medium14.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        AppSpacing.h6,
                        Text(
                          'Cars4Sale is a commercial property whose address received 12 UACS per ORR records.Please observe the location and report back to the case manager.',
                          style: AppStyle.book14.copyWith(
                            height: 1.5,
                            fontSize: 12.sp,
                          ),
                        ),
                        Divider(thickness: 1.h, color: AppColors.border),
                        AppSpacing.h4,
                        Text(
                          'Analyst Notes',
                          style: AppStyle.medium14.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        AppSpacing.h6,
                        Text(
                          'COP observed location and acquired video and photo of onsite building after hours. 2 males, suspicious activity. Next course of action to be: x, y z',
                          style: AppStyle.book14.copyWith(
                            height: 1.5,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    secondChild: SizedBox.shrink(),
                  ),

                  Divider(thickness: 1.h, color: AppColors.border),
                  AppSpacing.h4,
                  CustomButton(
                    buttonText: 'Collaborate',

                    onPressed: () {},
                    icon: Icons.message_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
