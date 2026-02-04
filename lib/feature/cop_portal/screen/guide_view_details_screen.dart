import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/cop_portal/model/education_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GuideViewDetailsScreen extends StatelessWidget {
  const GuideViewDetailsScreen({super.key, required this.guide});

  final Guide guide;

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
          if (guide.readTime != null)
            Padding(
              padding: EdgeInsets.only(right: 18.w),
              child: Text(guide.readTime!, style: AppStyle.medium12),
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
              Text(guide.description, style: AppStyle.book14),
              if (guide.thumbnailUrl != null) ...[
                AppSpacing.h10,
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    guide.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                ),
              ],
              AppSpacing.h10,
              Divider(thickness: 1, color: AppColors.border),
              AppSpacing.h12,
              if (guide.sections.isNotEmpty)
                ...guide.sections.map((section) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: AppStyle.medium14.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      AppSpacing.h6,
                      Text(section.content, style: AppStyle.book14),
                      AppSpacing.h12,
                    ],
                  );
                }),
              AppSpacing.h22,
            ],
          ),
        ),
      ),
    );
  }
}
