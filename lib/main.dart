import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
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
