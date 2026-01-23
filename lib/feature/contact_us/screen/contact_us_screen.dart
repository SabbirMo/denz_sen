import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/feature/contact_us/widget/contact_details_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _issueController = TextEditingController();

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: Text('Contact Us', style: AppStyle.semiBook20),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please send us your issue and we will get right back with a solution',
                style: AppStyle.book14,
              ),
              AppSpacing.h12,
              Text('Subject', style: AppStyle.book14),
              AppSpacing.h12,
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8.r),
                  color: Color(0xfff9f6f7),
                ),
                child: Text(
                  'How to track my submitted case?',
                  style: AppStyle.book16,
                ),
              ),
              AppSpacing.h18,
              TextField(
                autofocus: false,
                maxLines: 6,
                controller: _issueController,
                decoration: InputDecoration(
                  hintText: 'Describe your issue',
                  hintStyle: AppStyle.book14.copyWith(
                    color: AppColors.lightGrey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              AppSpacing.h22,
              CustomButton(
                buttonText: 'Submit',
                onPressed: () {
                  debugPrint('Issue Submitted');
                },
              ),
              AppSpacing.h18,
              Text(
                'Contact Details',
                style: AppStyle.semiBook14.copyWith(
                  color: AppColors.black,
                  fontSize: 18.sp,
                ),
              ),
              AppSpacing.h12,
              ContactDetailsField(
                text: '+855 93 980 148',
                icon: Icons.phone_outlined,
              ),
              ContactDetailsField(
                text: 'info@cop.com',
                icon: Icons.email_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
