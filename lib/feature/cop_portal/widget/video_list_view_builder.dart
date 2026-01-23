import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/cop_portal/model/cop_portal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoListViewBuilder extends StatelessWidget {
  const VideoListViewBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: copPortalData.length,
        itemBuilder: (_, index) {
          return Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 250.w,
                    height: 180.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.asset(
                        copPortalData[index].videoUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        copPortalData[index].duration,
                        style: AppStyle.medium12.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.h8,
              SizedBox(
                width: 250.w,
                child: Text(
                  copPortalData[index].title,
                  style: AppStyle.medium14.copyWith(color: AppColors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
      ),
    );
  }
}
