import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CopPartalCommsScreen extends StatelessWidget {
  const CopPartalCommsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  AppSpacing.h8,
                  MessageWidget(
                    name: 'Officer John',
                    message:
                        'I need you to do an observation of an office building on the Cars4Sale car lot on a Sat.',
                    time: '11:00',
                    avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
                    color: AppColors.primaryColor,
                    rank: 'assets/icons/rank1.png',
                  ),
                  MessageWidget(
                    name: 'Martha',
                    message:
                        'Understood. I can observe next weekend if that’s ok? I do have their office hours.',
                    time: '11:01',
                    avatar: 'https://randomuser.me/api/portraits/women/2.jpg',
                    color: AppColors.pink,
                    rank: 'assets/icons/rank1.png',
                  ),
                  MessageWidget(
                    name: 'Nathan',
                    message: 'I’ll keep an eye out too',
                    time: '11:02',
                    avatar: 'https://randomuser.me/api/portraits/men/3.jpg',
                    color: AppColors.brone,
                    rank: 'assets/icons/rank1.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String name, message, time, avatar;
  final Color color;
  final bool hasThread;
  final bool isReply;
  final String rank;

  const MessageWidget({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    required this.color,
    this.hasThread = false,
    this.isReply = false,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatar)),
              if (hasThread)
                Expanded(
                  child: Container(width: 2, color: Colors.grey.shade300),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Image.asset(rank, width: 24.w, height: 24.h),
                    SizedBox(width: 8.w),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
