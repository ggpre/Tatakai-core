import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Helper class for managing fonts with Google Fonts fallback
class AppFonts {
  /// Get Outfit text style with Google Fonts fallback
  static TextStyle outfit({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    try {
      return GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
      );
    } catch (e) {
      // Fallback to system font if Google Fonts fails
      return TextStyle(
        fontFamily: 'Outfit',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
      );
    }
  }
  
  /// Get Inter text style with Google Fonts fallback
  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    try {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
      );
    } catch (e) {
      // Fallback to system font if Google Fonts fails
      return TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
      );
    }
  }
  
  /// Get a themed text theme using Google Fonts
  static TextTheme getTextTheme({required bool isDark}) {
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark 
        ? Colors.white.withOpacity(0.6) 
        : Colors.black.withOpacity(0.6);
    
    return GoogleFonts.outfitTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor.withOpacity(0.87),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: secondaryColor,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: secondaryColor,
        ),
      ),
    );
  }
}
