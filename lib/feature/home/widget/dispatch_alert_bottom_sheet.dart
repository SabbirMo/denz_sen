import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/firebase/provider/new_dispatch_details_accept_provider.dart';
import 'package:denz_sen/firebase/provider/new_dispathc_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DispatchAlertBottomSheet {
  static void show(BuildContext context, {dynamic id}) async {
    // Save dispatch_id to SharedPreferences if provided
    if (id != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('dispatch_id', id.toString());
        debugPrint('✅ Dispatch ID saved: $id');
      } catch (e) {
        debugPrint('❌ Error saving dispatch_id: $e');
      }
    }

    // Fetch dispatch details
    final provider = Provider.of<NewDispathcDetailsProvider>(
      context,
      listen: false,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Fetch details
    final success = await provider.fetchDispatchDetails();

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (!success) {
      // Show error if failed
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Failed to load dispatch details',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Clear any previous error messages before showing bottom sheet
    if (context.mounted) {
      Provider.of<NewDispatchDetailsAcceptProvider>(
        context,
        listen: false,
      ).clearError();
    }

    // Show bottom sheet with data
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer<NewDispathcDetailsProvider>(
        builder: (context, provider, child) {
          final dispatch = provider.dispatchDetails;

          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 60.w,
                    height: 6.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.grey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                ),
                AppSpacing.h10,
                Text(
                  'New Dispatch',
                  style: AppStyle.semiBook18.copyWith(
                    fontSize: 20.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.h4,
                Divider(color: AppColors.border, thickness: 1.h),
                AppSpacing.h6,
                Text(
                  'Case # ${dispatch?.caseNumber ?? 'N/A'}',
                  style: AppStyle.semiBook16,
                ),
                AppSpacing.h10,
                if (dispatch?.maxSlots != null && dispatch?.slotsFilled != null)
                  CaseRowWidget(
                    slotsText: 'Slots',
                    slotsValue: '${dispatch!.slotsFilled}/${dispatch.maxSlots}',
                  ),
                if (dispatch?.date != null)
                  CaseRowWidget(
                    slotsText: 'Date',
                    slotsValue: dispatch!.date!.split('T')[0],
                  ),
                CaseRowWidget(
                  slotsText: 'Address',
                  slotsValue: dispatch?.address ?? 'N/A',
                ),
                if (dispatch?.status != null)
                  CaseRowWidget(
                    slotsText: 'Status',
                    slotsValue: dispatch!.status!,
                  ),
                AppSpacing.h8,
                Text(
                  'Details',
                  style: AppStyle.semiBook18.copyWith(
                    fontSize: 20.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dispatch?.description ?? 'No description available.',
                  style: AppStyle.book14,
                ),
                AppSpacing.h4,
                Divider(color: AppColors.border, thickness: 1.h),
                AppSpacing.h6,
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Do you wish to accept this assignment?',
                    style: AppStyle.semiBook14.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AppSpacing.h10,
                Consumer<NewDispatchDetailsAcceptProvider>(
                  builder: (context, acceptProvider, _) {
                    if (acceptProvider.errorMessage != null) {
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.red, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    acceptProvider.errorMessage!,
                                    style: AppStyle.semiBook14.copyWith(
                                      color: Colors.red.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.h10,
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
                GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                    childAspectRatio: 3.5,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Consumer<NewDispatchDetailsAcceptProvider>(
                      builder: (context, ref, _) => CustomButton(
                        buttonText: ('Yes'),
                        backgroundColor: AppColors.green,
                        onPressed: ref.isAccepting
                            ? null
                            : () async {
                                final success = await ref.acceptDispatch();
                                if (success && context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Dispatch accepted successfully!',
                                      ),
                                      backgroundColor: AppColors.green,
                                    ),
                                  );
                                }
                                // Error message will be shown inline above buttons
                              },
                      ),
                    ),
                    CustomButton(
                      buttonText: ('No'),
                      backgroundColor: AppColors.red,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CaseRowWidget extends StatelessWidget {
  const CaseRowWidget({
    super.key,
    required this.slotsText,
    required this.slotsValue,
  });

  final String slotsText;
  final String slotsValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(slotsText, style: AppStyle.medium14),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              slotsValue,
              style: AppStyle.semiBook14.copyWith(color: AppColors.black),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
