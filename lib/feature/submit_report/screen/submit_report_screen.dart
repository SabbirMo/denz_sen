import 'dart:io';
import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/core/widget/custom_filed.dart';
import 'package:denz_sen/core/widget/location_picker_widget.dart';
import 'package:denz_sen/feature/submit_report/provider/report_submit_provider.dart';
import 'package:denz_sen/feature/success_screen/success_screen_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SubmitReportScreen extends StatefulWidget {
  final LatLng? preSelectedLocation;

  const SubmitReportScreen({super.key, this.preSelectedLocation});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _actionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set pre-selected location from home screen if available
    if (widget.preSelectedLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<ReportSubmitProvider>(
          context,
          listen: false,
        );
        provider.setLocation(
          widget.preSelectedLocation!.latitude,
          widget.preSelectedLocation!.longitude,
          'Location from map',
        );
        _addressController.text = 'Location selected from home map';
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _detailController.dispose();
    _actionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // API expects YYYY-MM-DD format
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _openLocationPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerWidget(
          onLocationSelected: (lat, lng, address) {
            Provider.of<ReportSubmitProvider>(
              context,
              listen: false,
            ).setLocation(lat, lng, address);
            _addressController.text = address;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Location selected successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitReport() async {
    // Validation
    if (_dateController.text.isEmpty) {
      _showError('Please select date of event');
      return;
    }
    if (_detailController.text.isEmpty) {
      _showError('Please enter detail of event');
      return;
    }
    if (_actionsController.text.isEmpty) {
      _showError('Please enter actions taken');
      return;
    }

    final provider = Provider.of<ReportSubmitProvider>(context, listen: false);

    if (provider.latitude == null || provider.longitude == null) {
      _showError('Please select location on map');
      return;
    }

    final success = await provider.submitReport(
      eventDate: _dateController.text,
      details: _detailController.text,
      actionsTaken: _actionsController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      state: _stateController.text.isEmpty ? null : _stateController.text,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      zipCode: _zipCodeController.text.isEmpty ? null : _zipCodeController.text,
      files: selectedFiles.isEmpty ? null : selectedFiles,
    );

    if (success) {
      // Clear form
      _dateController.clear();
      _addressController.clear();
      _stateController.clear();
      _cityController.clear();
      _zipCodeController.clear();
      _detailController.clear();
      _actionsController.clear();
      setState(() {
        selectedFiles.clear();
      });

      SuccessScreenBottomSheet.show(context, type: SuccessType.reportSubmitted);
    } else {
      _showError(provider.errorMessage ?? 'Failed to submit report');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: Consumer<ReportSubmitProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomField(
                      title: 'Date of Event *',
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: Icon(Icons.calendar_month_outlined),
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                    GestureDetector(
                      onTap: _openLocationPicker,
                      child: AbsorbPointer(
                        child: CustomField(
                          title: 'Address (Select from Map) *',
                          hintText: 'Tap to select location from map',
                          suffixIcon: Icon(
                            Icons.location_on_outlined,
                            color: provider.latitude != null
                                ? Colors.green
                                : AppColors.grey,
                          ),
                          controller: _addressController,
                        ),
                      ),
                    ),
                    if (provider.latitude != null && provider.longitude != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Location: ${provider.latitude?.toStringAsFixed(6)}, ${provider.longitude?.toStringAsFixed(6)}',
                                style: AppStyle.book14.copyWith(
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    CustomField(
                      title: 'State (Optional)',
                      hintText: 'Enter state',
                      controller: _stateController,
                    ),
                    CustomField(
                      title: 'City (Optional)',
                      hintText: 'Enter city',
                      controller: _cityController,
                    ),
                    CustomField(
                      title: 'Zip Code (Optional)',
                      hintText: 'Enter zip code',
                      type: TextInputType.number,
                      controller: _zipCodeController,
                    ),
                    CustomField(
                      title: 'Detail of Event *',
                      hintText: 'Enter details of the event',
                      maxLines: 5,
                      controller: _detailController,
                    ),
                    CustomField(
                      title: 'Actions Taken *',
                      hintText: 'Enter actions taken',
                      maxLines: 5,
                      controller: _actionsController,
                    ),
                    Text(
                      'Attach Files (Optional)',
                      style: AppStyle.book16.copyWith(color: AppColors.grey),
                    ),
                    AppSpacing.h8,
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
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.primaryColor,
                                ),
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
                      isLoading: provider.isLoading,
                      buttonText: 'Submit',
                      onPressed: provider.isLoading ? null : _submitReport,
                    ),
                    AppSpacing.h24,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
