import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/core/widget/custom_filed.dart';
import 'package:denz_sen/core/widget/header_section.dart';
import 'package:denz_sen/feature/auth/signin/screen/signin_screen.dart';
import 'package:denz_sen/feature/auth/singup/provider/singup_provider.dart';
import 'package:denz_sen/feature/verification/verification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _copIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isFirstBuild = true;

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _copIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<SingupProvider>(context, listen: false);
        provider.resetVisibility();
      });
      _isFirstBuild = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SingupProvider>(context);
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
                    suffixIcon: IconButton(
                      onPressed: () => provider.togglePasswordVisibility(),
                      icon: Icon(
                        provider.isPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    obsecureText: provider.isPassword,
                  ),
                  CustomField(
                    title: 'Confirm Password',
                    hintText: 'confirm password',
                    prefixIcon: SvgPicture.asset('assets/svgs/lock.svg'),
                    suffixIcon: IconButton(
                      onPressed: () => provider.toggleConfirmPasswordVisibility(),
                      icon: Icon(
                        provider.isConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    obsecureText: provider.isConfirmPassword,
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
