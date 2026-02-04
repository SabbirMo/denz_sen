import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/contact_us/screen/contact_us_screen.dart';
import 'package:denz_sen/feature/cop_portal/provider/education_provider.dart';
import 'package:denz_sen/feature/cop_portal/widget/guides_list_view_builder.dart';
import 'package:denz_sen/feature/cop_portal/widget/video_list_view_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CopPortalEducation extends StatefulWidget {
  const CopPortalEducation({super.key});

  @override
  State<CopPortalEducation> createState() => _CopPortalEducationState();
}

class _CopPortalEducationState extends State<CopPortalEducation> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EducationProvider>().getEducationHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Videos', style: AppStyle.semiBook16),
              AppSpacing.h6,
              const VideoListViewBuilder(),
              Text('Guides', style: AppStyle.semiBook16),
              const GuidesListViewBuilder(),
              AppSpacing.h16,
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need help with something?',
                            style: AppStyle.medium14.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          AppSpacing.h2,
                          Text(
                            'Contact us if you need help with your investigation.',
                            style: AppStyle.book14.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.white,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ContactUsScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Contact Us",
                              style: AppStyle.medium14.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Image.asset('assets/icons/ques.png'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
