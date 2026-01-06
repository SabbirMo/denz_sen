import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/feature/success_screen/success_screen_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum OtpSource { signup, passwordReset }

class VerificationPage {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const _VerificationBottomSheet();
      },
    );
  }
}

class _VerificationBottomSheet extends StatefulWidget {
  const _VerificationBottomSheet();

  @override
  State<_VerificationBottomSheet> createState() =>
      _VerificationBottomSheetState();
}

class _VerificationBottomSheetState extends State<_VerificationBottomSheet> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isOtpFilled = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _checkOtpFilled() {
    setState(() {
      _isOtpFilled = _otpControllers.every(
        (controller) => controller.text.isNotEmpty,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.w),
              topRight: Radius.circular(16.w),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                AppSpacing.h8,
                BottomSheetIconText(title: 'Verify Your Account'),
                AppSpacing.h10,
                CircleAvatar(
                  radius: 40.r, // size of the avatar
                  backgroundColor: AppColors.grey.withValues(
                    alpha: 0.1,
                  ), // light gray background
                  child: Icon(
                    Icons.person, // default profile icon
                    size: 40.r, // icon size
                    color: AppColors.primaryColor, // icon color
                  ),
                ),
                AppSpacing.h10,
                Text('Jhon Doe', style: AppStyle.semiBook16),
                AppSpacing.h2,
                Text(
                  'jhondoe@mail.com',
                  style: AppStyle.book14.copyWith(fontSize: 12.sp),
                ),
                AppSpacing.h16,
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.error,
                      color: AppColors.primaryColor,
                      size: 28.sp,
                    ),
                    title: Text(
                      'We have send you 6 digits verification code to your email. Please kindly check',
                      style: AppStyle.book16.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                AppSpacing.h16,
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
                AppSpacing.h28,

                CustomButton(
                  onPressed: _isOtpFilled
                      ? () {
                          Navigator.of(context).pop();

                          SuccessScreenBottomSheet.show(context);
                        }
                      : null,
                  buttonText: 'Verify',
                  backgroundColor: _isOtpFilled
                      ? AppColors.primaryColor
                      : AppColors.grey.withValues(alpha: 0.5),
                ),

                AppSpacing.h32,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomSheetIconText extends StatelessWidget {
  const BottomSheetIconText({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
        ),
        Text(title, style: AppStyle.semiBook18),
      ],
    );
  }
}
