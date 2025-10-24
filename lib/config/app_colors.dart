import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient colors
  static const Color primaryPink = Color(0xFFFF69B4);
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color primaryGreen = Color(0xFF9ACD32);
  static const Color primaryBlue = Color(0xFF00BFFF);
  static const Color primaryPurple = Color(0xFF9C27B0);

  // Gradient combinations
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPink, primaryGold, primaryGreen, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient profileGradient = LinearGradient(
    colors: [primaryPink, primaryGold, primaryGreen, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient categoryGradient = LinearGradient(
    colors: [primaryPink, primaryGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);

  // Background colors
  static const Color backgroundPrimary = Colors.white;
  static const Color backgroundSecondary = Color(0xFFF8F9FA);
  static const Color backgroundTertiary = Color(0xFFF1F3F4);

  // Border colors
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color borderMedium = Color(0xFFCCCCCC);
  static const Color borderDark = Color(0xFF999999);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Social colors
  static const Color likeRed = Color(0xFFE91E63);
  static const Color saveBlue = Color(0xFF2196F3);
  static const Color commentGreen = Color(0xFF4CAF50);

  // Tab colors
  static const Color tabActive = Colors.black;
  static const Color tabInactive = Color(0xFF999999);

  // Button colors
  static const Color buttonPrimary = Colors.black;
  static const Color buttonSecondary = Color(0xFFF5F5F5);
  static const Color buttonSuccess = Color(0xFF4CAF50);
  static const Color buttonDanger = Color(0xFFF44336);

  // Category colors
  static const List<Color> categoryColors = [
    primaryPink,
    primaryGold,
    primaryGreen,
    primaryBlue,
    primaryPurple,
  ];

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
}

