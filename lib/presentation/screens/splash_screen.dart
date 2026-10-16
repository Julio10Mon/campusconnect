import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/logo_app.dart';
import '../widgets/motion.dart';

/// Splash
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: reduced ? 1 : 0, end: 1),
          duration: Motion.slow,
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
          ),
          child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LogoApp(size: 120),
            SizedBox(height: 20),
            Text(
              AppStrings.appName,
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.universityName,
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
