
import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/core/widget/custom_filed.dart';
import 'package:denz_sen/core/widget/header_section.dart';
import 'package:denz_sen/feature/auth/forgot_password/forgot_password_bottom_sheet.dart';
import 'package:denz_sen/feature/auth/signin/provider/signin_provider.dart';
import 'package:denz_sen/feature/auth/singup/screen/signup_screen.dart';
import 'package:denz_sen/feature/home/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isFirstBuild = true;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<SigninProvider>(context, listen: false);
        provider.resetVisibility();
      });
      _isFirstBuild = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SigninProvider>(context);
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
                    controller: _emailController,
                    prefixIcon: SvgPicture.asset('assets/svgs/sms.svg'),
                    type: TextInputType.emailAddress,
                  ),
                  CustomField(
                    title: 'Password',
                    hintText: 'password',
                    controller: _passwordController,
                    prefixIcon: SvgPicture.asset('assets/svgs/lock.svg'),
                    suffixIcon: IconButton(
                      onPressed: () {
                        provider.togglePasswordVisibility();
                      },
                      icon: provider.isPassword
                          ? Icon(Icons.visibility_off_outlined)
                          : Icon(Icons.visibility_outlined),
                    ),
                    obsecureText: provider.isPassword,
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
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter email and password'),
                          ),
                        );
                        return;
                      }

                      debugPrint('Email: $email, Password: $password');

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
