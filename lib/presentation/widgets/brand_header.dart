import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'logo_app.dart';

/// Encabezado de marca
class BrandHeader extends StatelessWidget {
  final bool compact;
  const BrandHeader({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 64.0 : 84.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, compact ? 28 : 36, 24, compact ? 28 : 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.34),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: LogoApp(size: size, borderRadius: BorderRadius.circular(size * 0.26)),
          ),
          SizedBox(height: compact ? 12 : 18),
          Text(
            AppStrings.appName,
            style: TextStyle(color: Colors.white, fontSize: compact ? 22 : 27, fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          if (!compact) ...[
            const SizedBox(height: 6),
            Text(
              AppStrings.universityName,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 12.5, height: 1.3),
            ),
          ],
        ],
      ),
    );
  }
}
