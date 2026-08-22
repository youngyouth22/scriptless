import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/app_typography.dart';

/// This class is used to define the themes for the application.
abstract class AppThemes {
  /// The light theme of the application.
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme(),
    dividerTheme: const DividerThemeData(color: Colors.transparent),
    navigationBarTheme: const NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.grey100),
        borderRadius: BorderRadius.all(Radius.circular(96)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.grey100),
        borderRadius: BorderRadius.all(Radius.circular(96)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.purpleHard),
        borderRadius: BorderRadius.all(Radius.circular(96)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.red),
        borderRadius: BorderRadius.all(Radius.circular(96)),
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      hintStyle: AppTypography.bodyMRegular.copyWith(
        color: AppColors.grey400,
      ),
    ),
    scaffoldBackgroundColor: AppColors.grey50,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
