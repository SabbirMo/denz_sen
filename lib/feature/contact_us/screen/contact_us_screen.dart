import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/feature/contact_us/provider/contact_us_provider.dart';
import 'package:denz_sen/feature/contact_us/widget/contact_details_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
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
              TextField(
                autofocus: false,
                controller: _subjectController,
                decoration: InputDecoration(
                  hintText: 'Subject',
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
              Consumer<ContactUsProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    buttonText: 'Submit',
                    isLoading: provider.isLoading,
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            final contactProvider =
                                Provider.of<ContactUsProvider>(
                                  context,
                                  listen: false,
                                );

                            // Validation
                            if (_subjectController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a subject'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (_issueController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please describe your issue'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Call API
                            final success = await contactProvider.sendContactUs(
                              subject: _subjectController.text.trim(),
                              description: _issueController.text.trim(),
                            );

                            if (context.mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      contactProvider.successMessage ??
                                          'Message sent successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                // Clear fields
                                _subjectController.clear();
                                _issueController.clear();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      contactProvider.errorMessage ??
                                          'Failed to send message',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  );
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
