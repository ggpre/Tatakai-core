import 'package:flutter/material.dart';

class AppThemes {
  // Theme enum
  static const String defaultTheme = 'default_dark';
  
  static final Map<String, ThemeData> themes = {
    'default_dark': _buildTheme(
      primary: const Color(0xFFAB47BC), // Purple
      secondary: const Color(0xFFEC407A), // Pink
      background: const Color(0xFF0A0A0F), // Very dark blue-black
      surface: const Color(0xFF1A1525), // Dark purple-tinted
      isDark: true,
    ),
    'default_light': _buildTheme(
      primary: const Color(0xFF7C3AED),
      secondary: const Color(0xFFA855F7),
      background: const Color(0xFFFAFAFA),
      surface: const Color(0xFFFFFFFF),
      isDark: false,
    ),
    'cyberpunk': _buildTheme(
      primary: const Color(0xFFFF00FF),
      secondary: const Color(0xFF00FFFF),
      background: const Color(0xFF0A0A0A),
      surface: const Color(0xFF1A0A1A),
      isDark: true,
    ),
    'ocean': _buildTheme(
      primary: const Color(0xFF0EA5E9),
      secondary: const Color(0xFF06B6D4),
      background: const Color(0xFF0C1821),
      surface: const Color(0xFF1A2332),
      isDark: true,
    ),
    'forest': _buildTheme(
      primary: const Color(0xFF10B981),
      secondary: const Color(0xFF34D399),
      background: const Color(0xFF0A1410),
      surface: const Color(0xFF152822),
      isDark: true,
    ),
    'sunset': _buildTheme(
      primary: const Color(0xFFF97316),
      secondary: const Color(0xFFFB923C),
      background: const Color(0xFF1A0F0A),
      surface: const Color(0xFF2A1A14),
      isDark: true,
    ),
    'midnight': _buildTheme(
      primary: const Color(0xFF6366F1),
      secondary: const Color(0xFF818CF8),
      background: const Color(0xFF050510),
      surface: const Color(0xFF0F0F1A),
      isDark: true,
    ),
    'rose': _buildTheme(
      primary: const Color(0xFFE11D48),
      secondary: const Color(0xFFF43F5E),
      background: const Color(0xFF1A0A0F),
      surface: const Color(0xFF2A1419),
      isDark: true,
    ),
    'emerald': _buildTheme(
      primary: const Color(0xFF059669),
      secondary: const Color(0xFF10B981),
      background: const Color(0xFF0A1410),
      surface: const Color(0xFF14241F),
      isDark: true,
    ),
    'amber': _buildTheme(
      primary: const Color(0xFFF59E0B),
      secondary: const Color(0xFFFBBF24),
      background: const Color(0xFF1A1410),
      surface: const Color(0xFF2A231A),
      isDark: true,
    ),
    'slate': _buildTheme(
      primary: const Color(0xFF475569),
      secondary: const Color(0xFF64748B),
      background: const Color(0xFF0F1419),
      surface: const Color(0xFF1E2530),
      isDark: true,
    ),
    'cherry_blossom': _buildTheme(
      primary: const Color(0xFFEC4899),
      secondary: const Color(0xFFF472B6),
      background: const Color(0xFF1A0A14),
      surface: const Color(0xFF2A1424),
      isDark: true,
    ),
    'matrix': _buildTheme(
      primary: const Color(0xFF00FF41),
      secondary: const Color(0xFF00D936),
      background: const Color(0xFF0D0D0D),
      surface: const Color(0xFF001A00),
      isDark: true,
    ),
    'dracula': _buildTheme(
      primary: const Color(0xFFBD93F9),
      secondary: const Color(0xFFFF79C6),
      background: const Color(0xFF282A36),
      surface: const Color(0xFF44475A),
      isDark: true,
    ),
    'nord': _buildTheme(
      primary: const Color(0xFF88C0D0),
      secondary: const Color(0xFF81A1C1),
      background: const Color(0xFF2E3440),
      surface: const Color(0xFF3B4252),
      isDark: true,
    ),
    'tokyo_night': _buildTheme(
      primary: const Color(0xFF7AA2F7),
      secondary: const Color(0xFFBB9AF7),
      background: const Color(0xFF1A1B26),
      surface: const Color(0xFF24283B),
      isDark: true,
    ),
  };
  
  static ThemeData _buildTheme({
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required bool isDark,
  }) {
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      surface: surface,
      onSurface: isDark ? Colors.white : Colors.black,
      background: background,
      onBackground: isDark ? Colors.white : Colors.black,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: isDark 
            ? Colors.white.withOpacity(0.6) 
            : Colors.black.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white.withOpacity(0.87) : Colors.black.withOpacity(0.87),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
        ),
      ),
    );
  }
  
  static List<String> get themeNames => themes.keys.toList();
  
  static ThemeData getTheme(String themeName) {
    return themes[themeName] ?? themes[defaultTheme]!;
  }
  
  static String getThemeDisplayName(String themeName) {
    return themeName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
