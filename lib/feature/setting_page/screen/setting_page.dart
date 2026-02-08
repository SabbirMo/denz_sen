import 'dart:io';

import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/auth/signin/provider/signin_provider.dart';
import 'package:denz_sen/feature/auth/signin/screen/signin_screen.dart';
import 'package:denz_sen/feature/change_password/screen/change_password_screen.dart';
import 'package:denz_sen/feature/home/provider/dispatch_radius_provider.dart';
import 'package:denz_sen/feature/home/provider/profile_show_provider.dart';
import 'package:denz_sen/feature/home/widget/custom_slider.dart';
import 'package:denz_sen/feature/home/widget/dispatch_alert_bottom_sheet.dart';
import 'package:denz_sen/feature/setting_page/edit_information/edit_information_page.dart';
import 'package:denz_sen/feature/setting_page/provider/edit_information_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  double currentValue = 0;

  @override
  void initState() {
    super.initState();
    // Load profile data when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileShowProvider>().showProfile();
    });
  }

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
            onPressed: () async {
              final profileProvider = context.read<ProfileShowProvider>();
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => EditInformationProvider(),
                    child: EditInformationPage(
                      profileData: profileProvider.profile,
                    ),
                  ),
                ),
              );

              // Refresh profile if update was successful
              if (result == true && mounted) {
                context.read<ProfileShowProvider>().showProfile();
              }
            },
            icon: Icon(Icons.edit_square),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              Consumer<ProfileShowProvider>(
                builder: (_, ref, _) => Column(
                  children: [
                    CircleAvatar(
                      radius: 42.r,
                      backgroundColor: AppColors.grey.withValues(alpha: 0.1),
                      backgroundImage: _getImageProvider(ref),
                      child: _getImageProvider(ref) == null
                          ? Icon(
                              Icons.person,
                              size: 30.r,
                              color: AppColors.primaryColor,
                            )
                          : null,
                    ),
                    AppSpacing.h10,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Profile Info', style: AppStyle.semiBook16),
                    ),
                    AppSpacing.h8,
                    CaseRowWidget(
                      slotsText: 'Name',
                      slotsValue: ref.profile?.fullName ?? 'user',
                    ),
                    CaseRowWidget(
                      slotsText: 'COP ID',
                      slotsValue: ref.profile?.copId ?? 'A157Z239526',
                    ),
                    CaseRowWidget(
                      slotsText: 'Email',
                      slotsValue: ref.profile?.email ?? 'jacktyler@gmail.com',
                    ),
                    CaseRowWidget(
                      slotsText: 'Phone Number',
                      slotsValue: ref.profile?.phone ?? '999-222-4444',
                    ),
                    CaseRowWidget(
                      slotsText: 'Address',
                      slotsValue: ref.profile?.location ?? 'address not found',
                    ),
                  ],
                ),
              ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
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
              Consumer<DispatchRadiusProvider>(
                builder: (context, provider, _) {
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 6.h,
                          activeTrackColor: AppColors.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          inactiveTrackColor: AppColors.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          thumbColor: AppColors.primaryColor,
                          thumbShape: SquareSliderThumbShape(
                            thumbSize: 16,
                            borderRadius: 4,
                            thumbWidth: 24,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 0,
                          ),
                        ),
                        child: Slider(
                          value: provider.dispatchRadius,
                          min: 0,
                          max: 500,
                          onChanged: provider.isLoading
                              ? null
                              : (double newValue) {
                                  provider.setDispatchRadius(newValue);
                                },
                          onChangeEnd: (double value) async {
                            await provider.updateDispatchRadius(value);
                            if (provider.errorMessage != null && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.errorMessage!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      if (provider.isLoading)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Updating...',
                                style: AppStyle.book14.copyWith(
                                  color: AppColors.greyText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      AppSpacing.h10,
                      Row(
                        children: [
                          Text(
                            '${provider.dispatchRadius.toInt()} MI',
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
                    ],
                  );
                },
              ),
              AppSpacing.h18,
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ListTile(
                  onTap: () async {
                    // Show confirmation dialog
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text('Log Out', style: AppStyle.semiBook16),
                          content: Text(
                            'Are you sure you want to log out?',
                            style: AppStyle.book14,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext, false);
                              },
                              child: Text(
                                'Cancel',
                                style: AppStyle.semiBook14.copyWith(
                                  color: AppColors.greyText,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext, true);
                              },
                              child: Text(
                                'Log Out',
                                style: AppStyle.semiBook14.copyWith(
                                  color: AppColors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    // If user cancelled, return early
                    if (shouldLogout != true) return;

                    // Get the provider
                    if (!context.mounted) return;
                    final provider = Provider.of<SigninProvider>(
                      context,
                      listen: false,
                    );

                    // Perform logout
                    await provider.logout();

                    // Check if widget is still mounted before navigation
                    if (!context.mounted) return;

                    // Navigate to SignIn screen and remove all previous routes
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  leading: Icon(Icons.logout, color: AppColors.red),
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
      ),
    );
  }

  ImageProvider? _getImageProvider(ProfileShowProvider ref) {
    if (ref.profile?.avatarUrl == null || ref.profile!.avatarUrl!.isEmpty) {
      return null;
    }

    final avatarUrl = ref.profile!.avatarUrl!;

    if (avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    } else {
      try {
        final file = File(avatarUrl.replaceAll('file://', ''));
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (e) {
        debugPrint('Error loading file image: $e');
      }
    }

    return null;
  }
}
