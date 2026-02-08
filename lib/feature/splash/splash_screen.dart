import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/feature/auth/signin/screen/signin_screen.dart';
import 'package:denz_sen/feature/auth/singup/screen/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = VideoPlayerController.asset('assets/video/splash_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.setLooping(true);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'CERTIFIED OBSERVER PROFESSIONAL',
                    style: AppStyle.boldText,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.h6,
                  Text(
                    'Stay informed, Respond faster.\n Collaborate smarter.',
                    style: AppStyle.book16.copyWith(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.h14,
                  CustomButton(
                    buttonText: 'Get Started',
                    width: 180.w,
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                  ),

                  AppSpacing.h20,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppStyle.book16.copyWith(color: AppColors.white),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
