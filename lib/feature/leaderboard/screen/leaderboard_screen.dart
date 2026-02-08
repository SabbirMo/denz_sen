import 'dart:io';

import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/home/provider/profile_show_provider.dart';
import 'package:denz_sen/feature/leaderboard/provider/leaderboard_provider.dart';
import 'package:denz_sen/feature/leaderboard/widget/rank_badge_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch gamification data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().fetchGamificationData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard', style: AppStyle.semiBook20),
        centerTitle: true,
      ),
      body: Consumer<LeaderboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (provider.gamificationData == null) {
            return Center(
              child: Text(
                'No data available',
                style: AppStyle.book14.copyWith(color: AppColors.grey),
              ),
            );
          }

          final data = provider.gamificationData!;

          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () async {
              await provider.fetchGamificationData();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Profile Section
                  Consumer<ProfileShowProvider>(
                    builder: (context, ref, _) {
                      // Determine the image provider
                      Widget profileImage;

                      if (ref.profile?.avatarUrl != null &&
                          ref.profile!.avatarUrl!.isNotEmpty) {
                        if (ref.profile!.avatarUrl!.startsWith('http')) {
                          // Network image
                          profileImage = Image.network(
                            ref.profile!.avatarUrl!,
                            width: 100.w,
                            height: 100.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100.w,
                                height: 100.h,
                                color: AppColors.grey.withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 50.w,
                                  color: AppColors.primaryColor,
                                ),
                              );
                            },
                          );
                        } else {
                          // File image
                          try {
                            final file = File(
                              ref.profile!.avatarUrl!.replaceAll('file://', ''),
                            );
                            if (file.existsSync()) {
                              profileImage = Image.file(
                                file,
                                width: 100.w,
                                height: 100.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100.w,
                                    height: 100.h,
                                    color: AppColors.grey.withValues(
                                      alpha: 0.2,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 50.w,
                                      color: AppColors.primaryColor,
                                    ),
                                  );
                                },
                              );
                            } else {
                              // File doesn't exist
                              profileImage = Container(
                                width: 100.w,
                                height: 100.h,
                                color: AppColors.grey.withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.person,
                                  size: 50.w,
                                  color: AppColors.primaryColor,
                                ),
                              );
                            }
                          } catch (e) {
                            // Error handling file
                            profileImage = Container(
                              width: 100.w,
                              height: 100.h,
                              color: AppColors.grey.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.person,
                                size: 50.w,
                                color: AppColors.primaryColor,
                              ),
                            );
                          }
                        }
                      } else {
                        // No avatar URL
                        profileImage = Container(
                          width: 100.w,
                          height: 100.h,
                          color: AppColors.grey.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.person,
                            size: 50.w,
                            color: AppColors.primaryColor,
                          ),
                        );
                      }

                      return Center(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 2.w,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: profileImage,
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0, 15.h),
                              child: Builder(
                                builder: (context) {
                                  // Find current badge index based on unlocked badges
                                  int currentBadgeIndex = 0;
                                  for (int i = 0; i < data.badges.length; i++) {
                                    if (data.badges[i].isUnlocked) {
                                      currentBadgeIndex = i;
                                    }
                                  }
                                  return RankBadgeWidget(
                                    iconPath:
                                        'assets/icons/rank${currentBadgeIndex + 1}.png',
                                    size: 30,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 30.h),
                  Text(data.currentRank, style: AppStyle.semiBook18),
                  SizedBox(height: 10.h),
                  // Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: data.progressPercent / 100,
                              child: Container(
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${data.currentPoints} / ${data.nextRankPoints} Pts',
                        style: AppStyle.medium12,
                      ),
                      Text(
                        '${data.progressPercent.toInt()}%',
                        style: AppStyle.medium12,
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  // Current Pts Badge - Dynamic icon based on current rank
                  Builder(
                    builder: (context) {
                      // Find current badge index based on unlocked badges
                      int currentBadgeIndex = 0;
                      for (int i = 0; i < data.badges.length; i++) {
                        if (data.badges[i].isUnlocked) {
                          currentBadgeIndex = i;
                        }
                      }
                      return RankBadgeWidget(
                        iconPath:
                            'assets/icons/rank${currentBadgeIndex + 1}.png',
                        size: 80,
                        label: '${data.currentPoints} Pts',
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  const Divider(),
                  SizedBox(height: 20.h),
                  // Badges Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20.w,
                      mainAxisSpacing: 30.h,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: data.badges.length,
                    itemBuilder: (context, index) {
                      final badge = data.badges[index];
                      return Column(
                        children: [
                          RankBadgeWidget(
                            iconPath: 'assets/icons/rank${index + 1}.png',
                            isUnlocked: badge.isUnlocked,
                            size: 60,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            badge.name,
                            style: AppStyle.book14.copyWith(
                              color: badge.isUnlocked
                                  ? AppColors.black
                                  : AppColors.grey,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                          Text(
                            '${badge.minPoints} Pts',
                            style: AppStyle.book14.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
