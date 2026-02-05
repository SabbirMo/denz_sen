import 'dart:io';

import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/core/widget/custom_filed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class EditInformationPage extends StatefulWidget {
  const EditInformationPage({super.key});

  @override
  State<EditInformationPage> createState() => _EditInformationPageState();
}

class _EditInformationPageState extends State<EditInformationPage> {
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipCodeController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
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
                      backgroundImage: imageFile != null
                          ? FileImage(File(imageFile!.path)) as ImageProvider
                          : AssetImage('assets/images/profile.png'),
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
                controller: phoneNumberController,
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
              Text('Address Info', style: AppStyle.semiBook16),
              AppSpacing.h10,
              CustomField(
                title: "Address",
                hintText: "Enter your address",
                controller: addressController,
                suffixIcon: Icon(Icons.location_on_outlined),
              ),
              CustomField(
                title: "City",
                hintText: "Enter your city",
                controller: cityController,
                suffixIcon: Icon(Icons.location_city_outlined),
              ),
              CustomField(
                title: "State",
                hintText: "Enter your state",
                controller: stateController,
                suffixIcon: Icon(Icons.map_outlined),
              ),
              CustomField(
                title: "Zip Code",
                hintText: "Enter your zip code",
                type: TextInputType.number,
                controller: zipCodeController,
              ),
              AppSpacing.h20,
              CustomButton(buttonText: 'Save', onPressed: () {}),
              AppSpacing.h20,
            ],
          ),
        ),
      ),
    );
  }
}
