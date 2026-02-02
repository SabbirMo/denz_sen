import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum Status { active, closed, pending, dispatched }

class CaseStatesWidget extends StatelessWidget {
  const CaseStatesWidget({super.key, this.status});

  final Status? status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: status == Status.active
            ? AppColors.red.withValues(alpha: 0.2)
            : status == Status.closed
            ? AppColors.green.withValues(alpha: 0.2)
            : status == Status.pending
            ? Colors.orange.withValues(alpha: 0.2)
            : status == Status.dispatched
            ? Colors.blue.withValues(alpha: 0.2)
            : Colors.transparent,

        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status == Status.active
            ? 'Active'
            : status == Status.closed
            ? 'Closed'
            : status == Status.pending
            ? 'Pending'
            : status == Status.dispatched
            ? 'Dispatched'
            : '',
        style: AppStyle.semiBook14.copyWith(
          fontSize: 10.sp,
          color: status == Status.active
              ? AppColors.red
              : status == Status.closed
              ? AppColors.green
              : status == Status.pending
              ? Colors.orange
              : status == Status.dispatched
              ? Colors.blue
              : Colors.transparent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
