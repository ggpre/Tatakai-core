import 'package:flutter/material.dart';

class AppGradients {
  // Primary gradient (purple to pink)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFAB47BC), // Purple
      Color(0xFFEC407A), // Pink
    ],
  );

  // Secondary gradient (pink to orange)
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEC407A), // Pink
      Color(0xFFFF6B9D), // Light pink
    ],
  );

  // Dark overlay gradient for images
  static const LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0xCC000000), // 80% opacity black
    ],
  );

  // Card gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2A1F35), // Dark purple
      Color(0xFF1A1525), // Darker purple
    ],
  );

  // Shimmer gradient
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, -0.5),
    end: Alignment(1.0, 0.5),
    colors: [
      Color(0xFF1A1525),
      Color(0xFF2A1F35),
      Color(0xFF1A1525),
    ],
  );

  // Button gradient
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFAB47BC), // Purple
      Color(0xFFEC407A), // Pink
    ],
  );
}
