import 'package:denz_sen/core/refresh_token/refresh_token.dart';
import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/core/widget/custom_button.dart';
import 'package:denz_sen/feature/auth/signin/screen/signin_screen.dart';
import 'package:denz_sen/feature/auth/singup/screen/signup_screen.dart';
import 'package:denz_sen/feature/home/provider/dipatches_nearby_provider.dart';
import 'package:denz_sen/feature/home/provider/profile_show_provider.dart';
import 'package:denz_sen/feature/home/screen/home_screen.dart';
import 'package:denz_sen/firebase/firebase_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool isVideoReady = false;
  bool isCheckingAuth = true;
  final RefreshTokenProvider _refreshTokenProvider = RefreshTokenProvider();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Initialize Firebase Cloud Messaging
    _initializeFirebase();

    // Check authentication status first
    _checkAuthenticationStatus();

    _controller = VideoPlayerController.asset('assets/video/splash_video.mp4')
      ..initialize().then((_) {
        setState(() => isVideoReady = true);
        _controller.play();
        _controller.setLooping(true);
      });
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      debugPrint('🔍 Splash: Access token exists: ${accessToken != null}');
      debugPrint('🔍 Splash: Refresh token exists: ${refreshToken != null}');

      if (accessToken == null || refreshToken == null) {
        // No tokens → show splash screen with login/signup buttons
        debugPrint('❌ No tokens found, showing splash screen');
        setState(() => isCheckingAuth = false);
        return;
      }

      // Tokens exist, try to refresh access token proactively
      debugPrint('🔄 Tokens found, attempting proactive refresh...');
      final refreshed = await _refreshTokenProvider.refreshAccessToken();

      if (!mounted) return;

      if (refreshed) {
        // Successfully refreshed → clear provider data and go to home
        debugPrint('✅ Token refresh successful, clearing provider data...');

        // Clear all provider caches so they fetch fresh data
        context.read<DipatchesNearbyProvider>().clearData();
        context.read<ProfileShowProvider>().clearData();

        debugPrint('✅ Navigating to home screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Refresh failed → show splash screen for login
        debugPrint('❌ Token refresh failed, showing splash screen');
        setState(() => isCheckingAuth = false);
      }
    } catch (e) {
      debugPrint('❌ Error checking auth status: $e');
      setState(() => isCheckingAuth = false);
    }
  }

  Future<void> _initializeFirebase() async {
    print('🚀 Starting Firebase initialization...');
    try {
      await FirebaseNotificationService.initialize();
      print('✅ Firebase initialization completed');
    } catch (e) {
      print('❌ Firebase initialization error: $e');
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking authentication
    if (isCheckingAuth) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/mainIcon.png', width: 150, height: 150),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: AppColors.primaryColor),
            ],
          ),
        ),
      );
    }

    // Show splash screen with video if not authenticated
    return Scaffold(
      body: isVideoReady
          ? Stack(
              children: [
                // Background video
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

                // Gradient overlay + text + buttons
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 32.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CERTIFIED OBSERVER PROFESSIONAL',
                          style: AppStyle.boldText.copyWith(
                            fontSize: 22.sp, // responsive
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.h6,
                        Text(
                          'Stay informed, Respond faster.\nCollaborate smarter.',
                          style: AppStyle.book16.copyWith(
                            color: AppColors.white,
                            fontSize: 16.sp, // responsive
                          ),
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
                              style: AppStyle.book16.copyWith(
                                color: AppColors.white,
                                fontSize: 14.sp,
                              ),
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
                                  fontSize: 14.sp,
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
            )
          : const SizedBox.expand(), // show empty until video ready
    );
  }
}
