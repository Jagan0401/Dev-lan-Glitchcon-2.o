import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MediSynC Design System
/// Primary: #0099BB (teal-cyan)  ·  Background: #FFFFFF
/// Typography: Plus Jakarta Sans (body) + JetBrains Mono (code/ids)
abstract class AppColors {
  // Brand
  static const primary = Color(0xFF0099BB);
  static const primaryDark = Color(0xFF007799);
  static const primaryGlow = Color(0x660099BB);
  static const primarySubtle = Color(0x140099BB);

  // Surface
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8FAFC);
  static const surfaceGlass = Color(0xD9FFFFFF);
  static const cardBorder = Color(0x14000000);

  // Text
  static const textMain = Color(0xFF121212);
  static const textMuted = Color(0xFF555555);
  static const textLight = Color(0xFF94A3B8);
  static const textHint = Color(0xFFADB5BD);

  // Feedback
  static const success = Color(0xFF10B981);
  static const successBg = Color(0xFFECFDF5);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFFFBEB);
  static const error = Color(0xFFEF4444);
  static const errorBg = Color(0xFFFEF2F2);
  static const info = Color(0xFF3B82F6);
  static const infoBg = Color(0xFFEFF6FF);

  // Neutral
  static const divider = Color(0xFFE2E8F0);
  static const inputBg = Color(0xCCFFFFFF);
  static const inputFocusBg = Color(0xFFFFFFFF);
  static const chipBg = Color(0xFFF1F5F9);

  // Role badge colours
  static const doctorColor = Color(0xFF6366F1); // indigo
  static const coordinatorColor = Color(0xFF0099BB); // teal (primary)
  static const technicianColor = Color(0xFFF59E0B); // amber
  static const adminColor = Color(0xFFEF4444); // red
  static const superAdminColor = Color(0xFF8B5CF6); // violet
}

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryDark,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(),
      inputDecorationTheme: _buildInputTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      appBarTheme: _buildAppBarTheme(),
      cardTheme: _buildCardTheme(),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipBg,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Display — hero headings
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        color: AppColors.textMain,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: AppColors.textMain,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        color: AppColors.textMain,
      ),
      // Headline — section titles
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.textMain,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.textMain,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
      // Title — card headers, list headers
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      ),
      // Body — content text
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textMain,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMain,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),
      // Label — buttons, badges, chips
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: AppColors.textMain,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: AppColors.textMain,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textMuted,
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: AppColors.textHint,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
      floatingLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      errorStyle: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.error,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textMain,
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textMuted,
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.divider,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textMain,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: AppColors.textMain),
    );
  }

  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    );
  }
}

/// Mono style helper — for hospital IDs, codes, etc.
TextStyle monoStyle({
  double fontSize = 13,
  Color color = AppColors.textMain,
  FontWeight weight = FontWeight.w500,
}) => GoogleFonts.jetBrainsMono(
  fontSize: fontSize,
  fontWeight: weight,
  color: color,
);
