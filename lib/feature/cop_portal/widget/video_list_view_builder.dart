import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/cop_portal/provider/education_provider.dart';
import 'package:denz_sen/feature/cop_portal/screen/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class VideoListViewBuilder extends StatelessWidget {
  const VideoListViewBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
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
              provider.educationData!.videos.isEmpty) {
            return const Center(child: Text("No videos available"));
          }

          final videos = provider.educationData!.videos;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (_, index) {
              final video = videos[index];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (video.mediaUrl != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoPlayerScreen(videoUrl: video.mediaUrl!),
                          ),
                        );
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 250.w,
                          height: 180.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: video.thumbnailUrl != null
                                ? Image.network(
                                    video.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(Icons.error),
                                            ),
                                  )
                                : Container(color: Colors.grey),
                          ),
                        ),
                        if (video.duration != null)
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
                                video.duration!,
                                style: AppStyle.medium12.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        const Positioned.fill(
                          child: Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h8,
                  SizedBox(
                    width: 250.w,
                    child: Text(
                      video.title,
                      style: AppStyle.medium14.copyWith(color: AppColors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
          );
        },
      ),
    );
  }
}
