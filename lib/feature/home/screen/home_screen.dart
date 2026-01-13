import 'dart:io';
import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/feature/home/widget/custom_slider.dart';
import 'package:denz_sen/feature/home/widget/dispatch_alert_bottom_sheet.dart';
import 'package:denz_sen/feature/setting_page/screen/setting_page.dart';
import 'package:denz_sen/feature/submit_report/screen/submit_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double currentValue = 0;

  File? image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60.h,
        automaticallyImplyLeading: false,
        title: CustomHomeAppBar(
          userName: 'Jack Tyler',
          onLeaderboardTap: () {},
          onSettingsTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 340.w,
                  height: 200.h,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColors.black.withValues(alpha: .4),
                        width: 1.w,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(1.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.asset(
                          'assets/images/maps.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 12.h,
                  left: 12.w,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(
                        Icons.camera_alt_sharp,
                        size: 24.w,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 2.8,
              ),
              children: [
                CustomGridCard(
                  imagePath: 'assets/svgs/information.svg',
                  title: 'Submit Report',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SubmitReportScreen(),
                      ),
                    );
                  },
                ),
                CustomGridCard(
                  imagePath: 'assets/svgs/folder.svg',
                  title: 'My Cases',
                ),
                CustomGridCard(
                  imagePath: 'assets/svgs/radio.svg',
                  title: 'COP Portal',
                ),
                CustomGridCard(
                  imagePath: 'assets/svgs/message.svg',
                  title: 'My Messages',
                  showBadge: true,
                  badgeCount: 2,
                ),
              ],
            ),
            Text('Active Dispatches', style: AppStyle.semiBook16),
            AppSpacing.h8,
            Container(
              padding: EdgeInsets.all(16.w),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Image.asset('assets/icons/fileFace.png'),
                  AppSpacing.h8,
                  Text(
                    'No Dispatches Yet',
                    style: AppStyle.medium14.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            SafeArea(
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Dispatch View Range', style: AppStyle.semiBook14),
                        Spacer(),
                        Text('150', style: AppStyle.semiBook14),
                      ],
                    ),
                    AppSpacing.h8,
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6.h,
                        activeTrackColor: AppColors.white.withValues(alpha: 0.2),
                        inactiveTrackColor: AppColors.white.withValues(
                          alpha: 0.2,
                        ),
                        thumbColor: AppColors.white,
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
                          style: AppStyle.semiBook14,
                        ),
                        Spacer(),
                        Text('500 MI', style: AppStyle.semiBook14),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class CustomGridCard extends StatelessWidget {
  const CustomGridCard({
    super.key,
    this.imagePath,
    this.title,
    this.showBadge = false,
    this.badgeCount,
    this.onTap,
  });

  final String? imagePath;
  final String? title;
  final bool showBadge;
  final int? badgeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            showBadge
                ? Badge(
                    label: Text(
                      '${badgeCount ?? 0}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    child: SvgPicture.asset(
                      imagePath ?? '',
                      width: 22.w,
                      height: 22.h,
                    ),
                  )
                : SvgPicture.asset(imagePath ?? '', width: 22.w, height: 22.h),

            AppSpacing.w6,

            Text(
              title ?? '',
              style: AppStyle.medium14.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomHomeAppBar extends StatelessWidget {
  const CustomHomeAppBar({
    super.key,
    this.userName = 'Jack Tyler',
    this.profileImagePath = 'assets/images/profile.png',
    this.onLeaderboardTap,
    this.onSettingsTap,
  });

  final String userName;
  final String profileImagePath;
  final VoidCallback? onLeaderboardTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26.r,
          backgroundImage: AssetImage(profileImagePath),
        ),
        AppSpacing.w14,
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: 'Close',
              builder: (context) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 58.h),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/icons/alertIcon.png'),
                            AppSpacing.h12,
                            Text(
                              'Dispatch Alert!',
                              style: AppStyle.semiBook16.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            AppSpacing.h12,
                            Text(
                              'A dispatch in your area has been activated',
                              style: AppStyle.medium14.copyWith(
                                color: AppColors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            AppSpacing.h12,
                            CustomButton(
                              buttonText: 'See Details',
                              onPressed: () {
                                Navigator.of(context).pop();
                                DispatchAlertBottomSheet.show(context);
                              },
                              width: double.infinity,
                              backgroundColor: AppColors.white,
                              textColor: AppColors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello 👋', style: AppStyle.medium14),
              Text(userName, style: AppStyle.medium16),
            ],
          ),
        ),
        const Spacer(),
        Row(
          children: [
            _circleIcon(Icons.leaderboard_outlined, onLeaderboardTap),
            AppSpacing.w10,
            _circleIcon(Icons.settings_outlined, onSettingsTap),
          ],
        ),
      ],
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24.w),
      ),
    );
  }
}
