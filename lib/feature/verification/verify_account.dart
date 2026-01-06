import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum OtpSource { signup, passwordReset }

class VerifyAccount extends StatefulWidget {
  const VerifyAccount({super.key, this.source, this.email});
  final OtpSource? source;
  final String? email;

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isOtpFilled = false; // track if all fields are filled

  void _checkOtpFilled() {
    final isFilled = _otpControllers.every(
      (controller) => controller.text.length == 1,
    );
    if (isFilled != _isOtpFilled) {
      setState(() {
        _isOtpFilled = isFilled;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Your Account', style: AppStyle.semiBook18),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              Text(
                widget.email ?? 'jhondoe@mail.com',
                style: AppStyle.book16.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: 46.w,
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: _focusNodes[index].hasFocus
                                ? AppColors.border
                                : AppColors.primaryColor,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 16,
                        ),
                      ),
                      cursorColor: AppColors.primaryColor,
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        _checkOtpFilled();
                      },
                    ),
                  ),
                ),
              ),
              AppSpacing.h24,
              CustomButton(
                onPressed: _isOtpFilled
                    ? () {
                        debugPrint('OTP Verified');
                      }
                    : null,
                buttonText: 'Verify',
                backgroundColor: _isOtpFilled
                    ? AppColors.primaryColor
                    : AppColors.grey.withValues(alpha: 0.5),
                isLoading: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
