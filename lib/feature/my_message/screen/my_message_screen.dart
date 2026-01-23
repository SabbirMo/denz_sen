import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/my_cases/widget/case_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class MyMessageScreen extends StatelessWidget {
  const MyMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        title: Text('My Messages', style: AppStyle.semiBook20),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xfff9f9f7),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Search messages',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              AppSpacing.h18,
              MyMessageCaseWidget(),
              MyMessageCaseWidget(
                widget: CaseStatesWidget(status: Status.closed),
              ),
              MyMessageCaseWidget(),
              MyMessageCaseWidget(
                widget: CaseStatesWidget(status: Status.closed),
              ),
              MyMessageCaseWidget(),
              MyMessageCaseWidget(
                widget: CaseStatesWidget(status: Status.closed),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyMessageCaseWidget extends StatelessWidget {
  const MyMessageCaseWidget({super.key, this.widget});

  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(0xfff9f6f7),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            child: SvgPicture.asset(
              'assets/svgs/messages.svg',
              width: 24.w,
              height: 24.h,
              // ignore: deprecated_member_use
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Case #00009',
                      style: AppStyle.medium14.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.w10,
                    CaseStatesWidget(
                      status: widget == null ? Status.active : Status.closed,
                    ),
                    Spacer(),
                    Text(
                      '8h ago',
                      style: AppStyle.medium12.copyWith(
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: 'Mod: ', style: AppStyle.medium12),
                      TextSpan(
                        text: 'Reviewing now, great job out there',
                        style: AppStyle.medium12.copyWith(
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
