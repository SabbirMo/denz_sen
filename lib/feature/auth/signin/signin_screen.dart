import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/core/widget/custom_filed.dart';
import 'package:denz_sen/core/widget/header_section.dart';
import 'package:denz_sen/feature/auth/forgot_password/forgot_password_bottom_sheet.dart';
import 'package:denz_sen/feature/auth/singup/signup_screen.dart';
import 'package:denz_sen/feature/home/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderSection(text: 'Sign In to COP'),
          AppSpacing.h26,
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomField(
                    title: 'Email',
                    hintText: 'email',
                    prefixIcon: SvgPicture.asset('assets/svgs/sms.svg'),
                  ),
                  CustomField(
                    title: 'Password',
                    hintText: 'password',
                    prefixIcon: SvgPicture.asset('assets/svgs/lock.svg'),
                    suffixIcon: Icon(Icons.visibility_off_outlined),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        ForgotPasswordBottomSheet.show(context);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppStyle.book16.copyWith(
                          color: AppColors.primaryColor,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primaryColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.h22,
                  CustomButton(
                    buttonText: 'Sign In',
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    width: double.infinity,
                  ),
                  AppSpacing.h20,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don’t have an account? ',
                        style: AppStyle.book16.copyWith(color: AppColors.grey),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: AppStyle.book16.copyWith(
                            color: AppColors.primaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h26,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
