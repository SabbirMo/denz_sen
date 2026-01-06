import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/core/widget/custom_filed.dart';
import 'package:denz_sen/core/widget/header_section.dart';
import 'package:denz_sen/feature/auth/signin/signin_screen.dart';
import 'package:denz_sen/feature/verification/verification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderSection(text: 'Sign Up to COP'),
          AppSpacing.h12,

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomField(
                    title: 'User Name',
                    hintText: 'username',
                    prefixIcon: SvgPicture.asset('assets/svgs/profile.svg'),
                  ),
                  CustomField(
                    title: 'Email',
                    hintText: 'email',
                    prefixIcon: SvgPicture.asset('assets/svgs/sms.svg'),
                  ),
                  CustomField(
                    title: 'COP ID',
                    hintText: 'COP ID',
                    prefixIcon: SvgPicture.asset('assets/svgs/cop.svg'),
                  ),
                  CustomField(
                    title: 'Password',
                    hintText: 'password',
                    prefixIcon: SvgPicture.asset('assets/svgs/lock.svg'),
                    suffixIcon: Icon(Icons.visibility_off_outlined),
                  ),
                  CustomField(
                    title: 'Confirm Password',
                    hintText: 'confirm password',
                    prefixIcon: SvgPicture.asset('assets/svgs/lock.svg'),
                    suffixIcon: Icon(Icons.visibility_off_outlined),
                  ),

                  AppSpacing.h12,
                  CustomButton(
                    buttonText: 'Sign Up',
                    onPressed: () {
                      VerificationPage.show(context);
                    },
                  ),
                  AppSpacing.h18,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppStyle.book16.copyWith(color: AppColors.black),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign In',
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
