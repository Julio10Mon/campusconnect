import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Tema claro y oscuro
class AppTheme {
  AppTheme._();

  static const _radiusSm = 10.0;
  static const _radiusMd = 16.0;
  static const _radiusLg = 22.0;

  /// Títulos: Bricolage Grotesque (carácter propio, buena lectura en pantallas
  /// pequeñas). Texto corrido y etiquetas: Public Sans (clara y sobria).
  static TextStyle _display(double size, FontWeight weight, Color color, {double? height, double spacing = -0.2}) {
    return GoogleFonts.bricolageGrotesque(fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: spacing);
  }

  static TextStyle _body(double size, FontWeight weight, Color color, {double? height, double spacing = 0}) {
    return GoogleFonts.publicSans(fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: spacing);
  }

  static TextTheme _textTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      headlineMedium: _display(32, FontWeight.w800, onSurface, height: 1.1, spacing: -0.6),
      headlineSmall: _display(26, FontWeight.w700, onSurface, height: 1.15, spacing: -0.4),
      titleLarge: _display(21, FontWeight.w700, onSurface, height: 1.2),
      titleMedium: _display(17, FontWeight.w600, onSurface, height: 1.25, spacing: -0.1),
      titleSmall: _body(14, FontWeight.w700, onSurface, height: 1.3),
      bodyLarge: _body(16, FontWeight.w400, onSurface, height: 1.5),
      bodyMedium: _body(14.5, FontWeight.w400, onSurface, height: 1.5),
      bodySmall: _body(12.5, FontWeight.w400, onSurfaceVariant, height: 1.4),
      labelLarge: _body(15, FontWeight.w600, onSurface, spacing: 0.1),
      labelMedium: _body(12.5, FontWeight.w600, onSurfaceVariant, spacing: 0.1),
      labelSmall: _body(11.5, FontWeight.w600, onSurfaceVariant, spacing: 0.1),
    );
  }

  static ThemeData get light => _build(
        brightness: Brightness.light,
        appBarColor: AppColors.navy,
        background: AppColors.bgLight,
        surface: AppColors.surfaceLight,
        surfaceAlt: AppColors.surfaceAltLight,
        onSurface: AppColors.onSurfaceLight,
        onSurfaceVariant: AppColors.onSurfaceVariantLight,
        outline: AppColors.outlineLight,
        primary: AppColors.blue,
        secondary: AppColors.orange,
        tertiary: AppColors.lightBlue,
        error: AppColors.error,
        shadowOpacity: 0.08,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        appBarColor: AppColors.navyDark,
        background: AppColors.bgDark,
        surface: AppColors.surfaceDark,
        surfaceAlt: AppColors.surfaceAltDark,
        onSurface: AppColors.onSurfaceDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        outline: AppColors.outlineDark,
        primary: AppColors.blueDark,
        secondary: AppColors.orangeDark,
        tertiary: AppColors.lightBlue,
        error: AppColors.errorDark,
        shadowOpacity: 0.35,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color appBarColor,
    required Color background,
    required Color surface,
    required Color surfaceAlt,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color primary,
    required Color secondary,
    required Color tertiary,
    required Color error,
    required double shadowOpacity,
  }) {
    // fromSeed
    final colorScheme = ColorScheme.fromSeed(seedColor: primary, brightness: brightness).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      tertiary: tertiary,
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceAlt,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outline,
      shadow: Colors.black,
    );

    final textTheme = _textTheme(onSurface, onSurfaceVariant);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      dividerTheme: DividerThemeData(color: outline, space: 1, thickness: 1),

      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _display(20, FontWeight.w700, Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          side: BorderSide(color: outline, width: 1),
        ),
        shadowColor: Colors.black.withValues(alpha: shadowOpacity),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.4),
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: outline, width: 1.4),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        hintStyle: TextStyle(color: onSurfaceVariant, fontSize: 14.5),
        labelStyle: TextStyle(color: onSurfaceVariant, fontSize: 14.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primary, width: 1.8)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: error, width: 1.4)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: error, width: 1.8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withValues(alpha: brightness == Brightness.dark ? 0.24 : 0.14),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        height: 66,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primary : onSurfaceVariant, size: 24);
        }),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: Colors.white,
        elevation: 3,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        labelStyle: TextStyle(color: onSurface, fontSize: 12.5, fontWeight: FontWeight.w600),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radiusLg)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: onSurface,
        contentTextStyle: TextStyle(color: surface, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: onSurfaceVariant,
        textColor: onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radiusSm)),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),

      iconTheme: IconThemeData(color: onSurfaceVariant),
    );
  }
}
