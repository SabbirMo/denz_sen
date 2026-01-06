import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/home/widget/custom_slider.dart';
import 'package:denz_sen/feature/home/widget/dispatch_alert_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  double currentValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppStyle.semiBook20),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add action for settings if needed
            },
            icon: Icon(Icons.edit_square),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42.r,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Profile Info', style: AppStyle.semiBook16),
            ),
            AppSpacing.h8,
            CaseRowWidget(slotsText: 'Name', slotsValue: 'Jack Tyler'),
            CaseRowWidget(
              slotsText: 'COP ID',
              slotsValue: 'jacktyler@A157Z239526',
            ),
            CaseRowWidget(
              slotsText: 'Email',
              slotsValue: 'jacktyler@gmail.com',
            ),
            CaseRowWidget(
              slotsText: 'Phone Number',
              slotsValue: '999-222-4444',
            ),
            AppSpacing.h10,
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Address Info', style: AppStyle.semiBook16),
            ),
            AppSpacing.h8,
            CaseRowWidget(slotsText: 'Address', slotsValue: '1234 Main St.'),
            CaseRowWidget(slotsText: 'City', slotsValue: 'Cape Coral'),
            CaseRowWidget(slotsText: 'State', slotsValue: 'Florida'),
            CaseRowWidget(slotsText: 'Zip Code', slotsValue: '33993'),
            AppSpacing.h10,
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Password', style: AppStyle.semiBook16),
            ),
            AppSpacing.h10,
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ListTile(
                onTap: () {
                  print('Change Password Tapped');
                },
                leading: SvgPicture.asset('assets/svgs/lock.svg'),
                title: Text(
                  "Change Password",
                  style: AppStyle.medium14.copyWith(color: AppColors.black),
                ),
                trailing: Icon(Icons.arrow_forward_ios_outlined, size: 20.w),
              ),
            ),
            AppSpacing.h18,
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Dispatch Range', style: AppStyle.semiBook16),
            ),
            AppSpacing.h10,
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 6.h,
                activeTrackColor: AppColors.primaryColor.withValues(alpha: 0.2),
                inactiveTrackColor: AppColors.primaryColor.withValues(
                  alpha: 0.2,
                ),
                thumbColor: AppColors.primaryColor,
                thumbShape: SquareSliderThumbShape(
                  thumbSize: 16,
                  borderRadius: 4,
                  thumbWidth: 24,
                ),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
              ),
              child: Slider(
                value: currentValue,
                min: 0,
                max: 500,
                onChanged: (double newValue) {
                  setState(() {
                    currentValue = newValue;
                  });
                },
              ),
            ),
            AppSpacing.h10,
            Row(
              children: [
                Text(
                  '${currentValue.toInt()} MI',
                  style: AppStyle.semiBook14.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
                Spacer(),
                Text(
                  '500 MI',
                  style: AppStyle.semiBook14.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
            AppSpacing.h18,
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ListTile(
                onTap: () {
                  print('Change Password Tapped');
                },
                leading: Icon(
                  IconData(0xe3b3, fontFamily: 'MaterialIcons'),
                  color: AppColors.red,
                ),
                title: Text(
                  "Log Out",
                  style: AppStyle.semiBook14.copyWith(color: AppColors.red),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 20.w,
                  color: AppColors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
