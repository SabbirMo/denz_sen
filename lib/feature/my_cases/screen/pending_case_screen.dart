import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/feature/home/widget/dispatch_alert_bottom_sheet.dart';
import 'package:denz_sen/feature/my_cases/provider/my_cases_pending_dispatch_provider.dart';
import 'package:denz_sen/feature/my_cases/provider/my_cases_provider.dart';
import 'package:denz_sen/feature/my_cases/widget/case_shimmer.dart';
import 'package:denz_sen/feature/my_cases/widget/case_status_widget.dart';
import 'package:denz_sen/feature/success_screen/case_close_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class PendingCaseScreen extends StatefulWidget {
  const PendingCaseScreen({super.key});

  @override
  State<PendingCaseScreen> createState() => _PendingCaseScreenState();
}

class _PendingCaseScreenState extends State<PendingCaseScreen> {
  int? expandedIndex;
  MyCasesPendingDispatchProvider? _dispatchProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MyCasesProvider>().fetchMyCases(status: 'Pending');
      _dispatchProvider = context.read<MyCasesPendingDispatchProvider>();
      _dispatchProvider?.addListener(_handleDispatchResult);
    });
  }

  @override
  void dispose() {
    _dispatchProvider?.removeListener(_handleDispatchResult);
    super.dispose();
  }

  void _handleDispatchResult() {
    final provider = context.read<MyCasesPendingDispatchProvider>();
    if (provider.success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dispatch created successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      // Collapse expanded item
      setState(() {
        expandedIndex = null;
      });
      // Auto refresh the pending cases list
      context.read<MyCasesProvider>().fetchMyCases(status: 'Pending');
    } else if (provider.success == false && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MyCasesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingPending) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => CaseShimmer(),
              ),
            );
          }

          if (provider.errorMessagePending != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessagePending!,
                    style: AppStyle.medium14.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchMyCases(status: 'Pending');
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.pendingCases.isEmpty) {
            return Center(
              child: Text(
                'No pending cases found',
                style: AppStyle.medium14.copyWith(color: AppColors.lightGrey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchMyCases(status: 'Pending');
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: ListView.builder(
                itemCount: provider.pendingCases.length,
                itemBuilder: (context, index) {
                  final caseData = provider.pendingCases[index];
                  final isExpanded = expandedIndex == index;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Color(0xfff9f6f7),
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              expandedIndex = isExpanded ? null : index;
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                caseData.caseNumber,
                                style: AppStyle.medium14.copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              CaseStatesWidget(status: Status.pending),
                              SizedBox(width: 8.w),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_outlined
                                    : Icons.keyboard_arrow_down_outlined,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Date:${caseData.date}',
                                style: AppStyle.medium12.copyWith(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                              TextSpan(
                                text: '\t\t\tTime:${caseData.time}',
                                style: AppStyle.medium12.copyWith(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedCrossFade(
                          duration: Duration(milliseconds: 200),
                          crossFadeState: isExpanded
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(thickness: 1.h, color: AppColors.border),
                              CaseRowWidget(
                                slotsText: 'Address',
                                slotsValue: caseData.address,
                              ),
                              AppSpacing.h10,
                              Text(
                                'Event Detail',
                                style: AppStyle.medium14.copyWith(
                                  color: AppColors.black,
                                ),
                              ),
                              AppSpacing.h6,
                              Text(
                                caseData.eventDetails,
                                style: AppStyle.book14.copyWith(
                                  height: 1.5,
                                  fontSize: 12.sp,
                                ),
                              ),
                              Divider(thickness: 1.h, color: AppColors.border),
                              AppSpacing.h4,
                              Text(
                                'Actions Taken',
                                style: AppStyle.medium14.copyWith(
                                  color: AppColors.black,
                                ),
                              ),
                              AppSpacing.h6,
                              Text(
                                caseData.actionsTaken,
                                style: AppStyle.book14.copyWith(
                                  height: 1.5,
                                  fontSize: 12.sp,
                                ),
                              ),
                              Divider(thickness: 1.h, color: AppColors.border),
                              AppSpacing.h4,
                              Row(
                                children: [
                                  Consumer<MyCasesPendingDispatchProvider>(
                                    builder: (context, ref, _) => Expanded(
                                      child: CustomButton(
                                        isLoading: ref.isLoading,
                                        buttonText: ' Create Dispatch',
                                        onPressed: () {
                                          ref.pendingDispatchCases(caseData.id);
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: CustomButton(
                                      buttonText: 'Close Case',
                                      backgroundColor: AppColors.border,
                                      textColor: AppColors.black,
                                      onPressed: () {
                                        CaseCloseBottomSheet.show(
                                          context,
                                          CaseCloseAction.okay,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          secondChild: SizedBox.shrink(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
