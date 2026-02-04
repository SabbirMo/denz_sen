import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/cop_portal/provider/education_provider.dart';
import 'package:denz_sen/feature/cop_portal/screen/guide_view_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class GuidesListViewBuilder extends StatelessWidget {
  const GuidesListViewBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 226.h,
      child: Consumer<EducationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (_, __) =>
                    Container(width: 250.w, height: 180.h, color: Colors.white),
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
              ),
            );
          }

          if (provider.educationData == null ||
              provider.educationData!.guides.isEmpty) {
            return const Center(child: Text("No guides available"));
          }

          final guides = provider.educationData!.guides;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final guide = guides[index];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GuideViewDetailsScreen(guide: guide),
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
                        child: guide.thumbnailUrl != null
                            ? Image.network(
                                guide.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.error)),
                              )
                            : Container(
                                color: Colors.grey,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                      ),
                    ),
                  ),
                  AppSpacing.h4,
                  SizedBox(
                    width: 250.w,
                    child: Text(
                      guide.title,
                      style: AppStyle.medium14.copyWith(color: AppColors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (guide.readTime != null)
                    SizedBox(
                      width: 250.w,
                      child: Text(
                        guide.readTime!,
                        style: AppStyle.medium14,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              );
            },
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemCount: guides.length,
          );
        },
      ),
    );
  }
}
