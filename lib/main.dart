import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/auth/forgot_password/provider/forgot_password_provider.dart';
import 'package:denz_sen/feature/auth/new_password/provider/new_password_provider.dart';
import 'package:denz_sen/feature/auth/signin/provider/signin_provider.dart';
import 'package:denz_sen/feature/auth/singup/provider/singup_provider.dart';
import 'package:denz_sen/feature/change_password/provider/change_password_provider.dart';
import 'package:denz_sen/feature/home/provider/google_maps_provider.dart';
import 'package:denz_sen/feature/my_cases/provider/my_cases_pending_dispatch_provider.dart';
import 'package:denz_sen/feature/my_cases/provider/my_cases_provider.dart';
import 'package:denz_sen/feature/my_message/provider/message_details_provider.dart';
import 'package:denz_sen/feature/my_message/provider/message_send_provider.dart';
import 'package:denz_sen/feature/my_message/provider/message_socket_provider.dart';
import 'package:denz_sen/feature/my_message/provider/my_message_provider.dart';
import 'package:denz_sen/feature/splash/splash_screen.dart';
import 'package:denz_sen/feature/verification/provider/verification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SigninProvider()),
        ChangeNotifierProvider(create: (_) => SingupProvider()),
        ChangeNotifierProvider(create: (_) => NewPasswordProvider()),
        ChangeNotifierProvider(create: (_) => ChangePasswordProvider()),
        ChangeNotifierProvider(create: (_) => VerificationProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
        ChangeNotifierProvider(create: (_) => GoogleMapsProvider()),
        ChangeNotifierProvider(create: (_) => MyCasesProvider()),
        ChangeNotifierProvider(create: (_) => MyMessageProvider()),
        ChangeNotifierProvider(create: (_) => MessageDetailsProvider()),
        ChangeNotifierProvider(create: (_) => MessageSendProvider()),
        ChangeNotifierProvider(create: (_) => MessageSocketProvider()),
        ChangeNotifierProvider(create: (_) => MyCasesPendingDispatchProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppStyle.lightTheme,
        home: const FullScreenWrapper(child: SplashScreen()),
      ),
    );
  }
}

class FullScreenWrapper extends StatefulWidget {
  final Widget child;

  const FullScreenWrapper({super.key, required this.child});

  @override
  State<FullScreenWrapper> createState() => _FullScreenWrapperState();
}

class _FullScreenWrapperState extends State<FullScreenWrapper>
    with WidgetsBindingObserver {
  bool _isImmersiveModeEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableImmersiveMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isImmersiveModeEnabled) {
        _enableImmersiveMode();
      }
    }
  }

  void _enableImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  void _disableImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Detect upward scroll from bottom
        if (details.delta.dy < -8) {
          if (_isImmersiveModeEnabled) {
            setState(() {
              _isImmersiveModeEnabled = false;
            });
            _disableImmersiveMode();

            // Re-enable immersive mode after delay
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && !_isImmersiveModeEnabled) {
                setState(() {
                  _isImmersiveModeEnabled = true;
                });
                _enableImmersiveMode();
              }
            });
          }
        }
      },
      child: widget.child,
    );
  }
}
