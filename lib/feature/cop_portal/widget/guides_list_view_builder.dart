import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/cop_portal/model/cop_portal_model.dart';
import 'package:denz_sen/feature/cop_portal/screen/guide_view_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GuidesListViewBuilder extends StatelessWidget {
  const GuidesListViewBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 226.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuideViewDetailsScreen(
                        guide: copPortalGuidesData[index],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 250.w,
                  height: 180.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.asset(
                      copPortalGuidesData[index].imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              AppSpacing.h4,
              SizedBox(
                width: 250.w,
                child: Text(
                  copPortalGuidesData[index].title,
                  style: AppStyle.medium14.copyWith(color: AppColors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 250.w,
                child: Text(
                  copPortalGuidesData[index].duration,
                  style: AppStyle.medium14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemCount: copPortalGuidesData.length,
      ),
    );
  }
}
