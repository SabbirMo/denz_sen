import 'dart:io';
import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/core/widget/custom_filed.dart';
import 'package:denz_sen/feature/success_screen/success_screen_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  List<File> selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedFiles.add(File(image.path));
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Report', style: AppStyle.semiBook20),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomField(
                title: 'Date of Event',
                hintText: 'mm/dd/yyyy',
                suffixIcon: Icon(Icons.calendar_month_outlined),
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              CustomField(
                title: 'Address',
                hintText: 'Enter address',
                suffixIcon: Icon(Icons.location_on_outlined),
              ),
              CustomField(
                title: 'State',
                hintText: 'Enter state',
                suffixIcon: Icon(Icons.location_on_outlined),
              ),
              CustomField(
                title: 'City',
                hintText: 'Enter city',
                suffixIcon: Icon(Icons.location_on_outlined),
              ),
              CustomField(title: 'Zip Code', hintText: 'Enter zip code'),
              CustomField(
                title: 'Detail of Event',
                hintText: 'Enter details of the event',
                maxLines: 5,
              ),
              CustomField(
                title: 'Actions Taken',
                hintText: 'Enter actions taken',
                maxLines: 5,
              ),

              Text(
                'Attach Files',
                style: AppStyle.book16.copyWith(color: AppColors.grey),
              ),
              SizedBox(
                height: 80.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...selectedFiles.asMap().entries.map((entry) {
                      int index = entry.key;
                      File file = entry.value;
                      return Container(
                        width: 80.w,
                        height: 80.h,
                        margin: EdgeInsets.only(right: 8.w),
                        child: Stack(
                          children: [
                            Container(
                              width: 80.w,
                              height: 80.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.primaryColor,
                                ),
                                image: DecorationImage(
                                  image: FileImage(file),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.black.withValues(
                                      alpha: 0.6,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: AppColors.primaryColor,
                            ),
                            AppSpacing.h2,
                            Text(
                              'Upload',
                              style: AppStyle.medium14.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h24,
              CustomButton(
                buttonText: 'Submit',
                onPressed: () {
                  SuccessScreenBottomSheet.show(
                    context,
                    type: SuccessType.reportSubmitted,
                  );
                },
              ),
              AppSpacing.h24,
            ],
          ),
        ),
      ),
    );
  }
}
