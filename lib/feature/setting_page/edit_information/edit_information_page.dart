import 'dart:io';

import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/core/widget/custom_filed.dart';
import 'package:denz_sen/feature/home/model/get_profile_model.dart';
import 'package:denz_sen/feature/setting_page/provider/edit_information_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditInformationPage extends StatefulWidget {
  final GetProfileModel? profileData;

  const EditInformationPage({super.key, this.profileData});

  @override
  State<EditInformationPage> createState() => _EditInformationPageState();
}

class _EditInformationPageState extends State<EditInformationPage> {
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate controllers with existing data
    if (widget.profileData != null) {
      fullNameController.text = widget.profileData!.fullName;
      phoneNumberController.text = widget.profileData!.phone ?? '';
      addressController.text = widget.profileData!.location ?? '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
  }

  XFile? imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    } else {
      debugPrint('No image selected.');
    }
  }

  Future<void> _saveProfile() async {
    final provider = context.read<EditInformationProvider>();

    // Validate inputs
    if (fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter your full name')));
      return;
    }

    if (phoneNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter your phone number')));
      return;
    }

    // Call API
    final success = await provider.updateUserInformation(
      fullName: fullNameController.text.trim(),
      phone: phoneNumberController.text.trim(),
      avatarUrl: imageFile?.path,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.successMessage ?? 'Profile updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Information', style: AppStyle.semiBook20),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 42.r,
                      backgroundColor: AppColors.grey.withValues(alpha: 0.1),
                      backgroundImage: imageFile != null
                          ? FileImage(File(imageFile!.path)) as ImageProvider
                          : (widget.profileData?.avatarUrl != null &&
                                    widget.profileData!.avatarUrl!.isNotEmpty
                                ? (widget.profileData!.avatarUrl!.startsWith(
                                            'http',
                                          )
                                          ? NetworkImage(
                                              widget.profileData!.avatarUrl!,
                                            )
                                          : FileImage(
                                              File(
                                                widget.profileData!.avatarUrl!
                                                    .replaceAll('file://', ''),
                                              ),
                                            ))
                                      as ImageProvider
                                : null),
                      child:
                          imageFile == null &&
                              (widget.profileData?.avatarUrl == null ||
                                  widget.profileData!.avatarUrl!.isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 30.r,
                              color: AppColors.primaryColor,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Icon(
                              Icons.edit_square,
                              size: 14.w,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h12,
              Text('Profile Info', style: AppStyle.semiBook16),
              AppSpacing.h10,
              CustomField(
                title: "Full Name",
                hintText: "Enter your  name",
                controller: fullNameController,
                prefixIcon: Icon(Icons.person_outline),
              ),

              AppSpacing.h4,
              CustomField(
                title: "Phone Number",
                hintText: "Enter your phone number",
                controller: phoneNumberController,
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              AppSpacing.h12,
              // Text('Address Info', style: AppStyle.semiBook16),
              // AppSpacing.h10,
              // CustomField(
              //   title: "Address",
              //   hintText: "Enter your address",
              //   controller: addressController,
              //   suffixIcon: Icon(Icons.location_on_outlined),
              // ),
              // CustomField(
              //   title: "City",
              //   hintText: "Enter your city",
              //   controller: cityController,
              //   suffixIcon: Icon(Icons.location_city_outlined),
              // ),
              // CustomField(
              //   title: "State",
              //   hintText: "Enter your state",
              //   controller: stateController,
              //   suffixIcon: Icon(Icons.map_outlined),
              // ),
              // CustomField(
              //   title: "Zip Code",
              //   hintText: "Enter your zip code",
              //   type: TextInputType.number,
              //   controller: zipCodeController,
              // ),
              AppSpacing.h20,
              Consumer<EditInformationProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    isLoading: provider.isLoading,
                    buttonText: 'Save',
                    onPressed: provider.isLoading ? null : _saveProfile,
                  );
                },
              ),
              AppSpacing.h20,
            ],
          ),
        ),
      ),
    );
  }
}
