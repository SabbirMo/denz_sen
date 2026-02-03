import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/my_cases/widget/case_status_widget.dart';
import 'package:denz_sen/feature/my_message/provider/my_message_provider.dart';
import 'package:denz_sen/feature/my_message/screen/message_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MyMessageScreen extends StatefulWidget {
  const MyMessageScreen({super.key});

  @override
  State<MyMessageScreen> createState() => _MyMessageScreenState();
}

class _MyMessageScreenState extends State<MyMessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      Provider.of<MyMessageProvider>(context, listen: false).fatchMessage();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterMessages(List<dynamic> messages) {
    if (_searchQuery.isEmpty) return messages;

    // Remove special characters and spaces for flexible search
    final cleanQuery = _searchQuery.replaceAll(RegExp(r'[-\s]'), '');

    return messages.where((message) {
      final caseNumber = (message.caseNumber ?? '').toLowerCase().replaceAll(
        RegExp(r'[-\s]'),
        '',
      );
      final lastMessage = (message.lastMessage ?? '').toLowerCase();
      final lastSender = (message.lastSender ?? '').toLowerCase();
      final caseStatus = (message.caseStatus ?? '').toLowerCase();

      return caseNumber.contains(cleanQuery) ||
          lastMessage.contains(_searchQuery) ||
          lastSender.contains(_searchQuery) ||
          caseStatus.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        title: Text('My Messages', style: AppStyle.semiBook20),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xfff9f9f7),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Search messages',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              AppSpacing.h18,
              Consumer<MyMessageProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) => MessageShimmer(),
                    );
                  }

                  final filteredMessages = _filterMessages(provider.messages);

                  if (filteredMessages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 50.h),
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No messages found'
                              : 'No messages match your search',
                          style: AppStyle.medium14.copyWith(
                            color: AppColors.lightGrey,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredMessages.length,
                    itemBuilder: (context, index) {
                      final message = filteredMessages[index];
                      return MyMessageCaseWidget(
                        message: message,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MessageDetailsPage(caseId: message.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageShimmer extends StatelessWidget {
  const MessageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(0xfff9f6f7),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            CircleAvatar(radius: 24.r, backgroundColor: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 100.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      AppSpacing.w10,
                      Container(
                        width: 60.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: 50.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
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

class MyMessageCaseWidget extends StatelessWidget {
  const MyMessageCaseWidget({super.key, required this.message, this.onTap});

  final dynamic message;
  final VoidCallback? onTap;

  Status _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Status.pending;
      case 'dispatched':
        return Status.dispatched;
      case 'closed':
        return Status.closed;
      default:
        return Status.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Color(0xfff9f6f7),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
              child: SvgPicture.asset(
                'assets/svgs/messages.svg',
                width: 24.w,
                height: 24.h,
                // ignore: deprecated_member_use
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        message.caseNumber ?? 'N/A',
                        style: AppStyle.medium14.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.w10,
                      CaseStatesWidget(
                        status: _getStatusFromString(
                          message.caseStatus ?? 'pending',
                        ),
                      ),
                      Spacer(),
                      Text(
                        message.lastActivity ?? '',
                        style: AppStyle.medium12.copyWith(
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${message.lastSender ?? 'Unknown'}: ',
                          style: AppStyle.medium12,
                        ),
                        TextSpan(
                          text: message.lastMessage ?? 'No message',
                          style: AppStyle.medium12.copyWith(
                            color: AppColors.lightGrey,
                          ),
                        ),
                      ],
                    ),
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
