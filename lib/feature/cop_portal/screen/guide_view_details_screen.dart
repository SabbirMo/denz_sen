import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/cop_portal/model/cop_portal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GuideViewDetailsScreen extends StatelessWidget {
  const GuideViewDetailsScreen({super.key, required this.guide});

  final CopPortalGuidesModel guide;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 18.w),
            child: Text(guide.duration, style: AppStyle.medium12),
          ),
        ],
        title: Text('Guide', style: AppStyle.semiBook20),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(guide.title, style: AppStyle.semiBook18),
              AppSpacing.h8,
              Text(
                'Learn how to safely and effectively capture information that supports your report and helps authorities take',
                style: AppStyle.book14,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset(guide.imageUrl, fit: BoxFit.cover),
              ),
              AppSpacing.h10,
              Divider(thickness: 1, color: AppColors.border),
              AppSpacing.h12,
              Text(
                'When reporting an incident or suspicious activity, proper evidence collection helps ensure that your report is credible and actionable. Follow these simple steps to gather useful, verifiable information while keeping yourself safe.',
                style: AppStyle.book14,
              ),
              AppSpacing.h10,
              Text(
                '1. Stay Safe First',
                style: AppStyle.medium14.copyWith(color: AppColors.black),
              ),
              AppSpacing.h6,
              Text(
                'Never put yourself in danger to obtain evidence. Observe from a distance if necessary, and avoid direct confrontation.',
                style: AppStyle.book14,
              ),
              AppSpacing.h12,
              Text(
                '2. Record Details Quickly',
                style: AppStyle.medium14.copyWith(color: AppColors.black),
              ),
              AppSpacing.h6,
              Text(
                'Note down what you saw, including time, date, location, and people involved. Fresh details are more accurate than recollections later.',
                style: AppStyle.book14,
              ),
              AppSpacing.h12,
              Text(
                '3. Capture Clear Media',
                style: AppStyle.medium14.copyWith(color: AppColors.black),
              ),
              AppSpacing.h6,
              Text(
                'If safe, take photos or short videos that clearly show what’s happening. Avoid zooming too far or taking unclear shots. Don’t edit or filter media before submitting it.',
                style: AppStyle.book14,
              ),
              AppSpacing.h22,
            ],
          ),
        ),
      ),
    );
  }
}
