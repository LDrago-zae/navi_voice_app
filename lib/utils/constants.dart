import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF7F8FA);
  static const Color primary = Color(0xFF6A5CFF);
  static const Color primaryLight = Color(0xFF6AD0FF);
  static const Color accent = Colors.deepPurpleAccent;
  static const Color card = Colors.white;
  static const Color cardShadow = Color(0x08000000);
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF757575);
  static const Color priceTag = Colors.black;
  static const Color priceText = Colors.white;
  static const Color star = Colors.amber;
  static const Color yellowTag = Color(0xFFFFF9C4);
  static const Color green = Colors.green;
  static const Color blue = Colors.blue;
  static const Color greenLight = Color(0xFFE8F5E9);
  static const Color blueLight = Color(0xFFE3F2FD);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF181A20);
  static const Color cardDark = Color(0xFF23243A);
  static const Color primaryDark = Color(0xFF6A5CFF);
  static const Color primaryLightDark = Color(0xFF6AD0FF);
  static const Color accentDark = Colors.deepPurpleAccent;
  static const Color textPrimaryDark = Color(0xFFF7F8FA);
  static const Color textSecondaryDark = Color(0xFFB0B3C7);
  static const Color priceTagDark = Color(0xFF23243A);
  static const Color priceTextDark = Color(0xFFF7F8FA);
  static const Color starDark = Colors.amber;
  static const Color yellowTagDark = Color(0xFF3A3B5A);
  static const Color greenDark = Colors.greenAccent;
  static const Color blueDark = Colors.lightBlueAccent;
  static const Color greenLightDark = Color(0xFF263238);
  static const Color blueLightDark = Color(0xFF1A237E);

  // Utility functions for theme-based color selection
  static Color getTextPrimary(bool isDark) =>
      isDark ? textPrimaryDark : textPrimary;
  static Color getTextSecondary(bool isDark) =>
      isDark ? textSecondaryDark : textSecondary;
  static Color getCardColor(bool isDark) => isDark ? cardDark : card;
  static Color getCardShadow(bool isDark) =>
      isDark ? Colors.black26 : cardShadow;
  static Color getPrimary(bool isDark) => isDark ? primaryDark : primary;
  static Color getPrimaryLight(bool isDark) =>
      isDark ? primaryLightDark : primaryLight;
  static Color getPriceTag(bool isDark) => isDark ? priceTagDark : priceTag;
  static Color getPriceText(bool isDark) => isDark ? priceTextDark : priceText;
  static Color getYellowTag(bool isDark) => isDark ? yellowTagDark : yellowTag;
  static Color getStar(bool isDark) => isDark ? starDark : star;
  static Color getGreen(bool isDark) => isDark ? greenDark : green;
  static Color getBlue(bool isDark) => isDark ? blueDark : blue;
  static Color getGreenLight(bool isDark) =>
      isDark ? greenLightDark : greenLight;
  static Color getBlueLight(bool isDark) => isDark ? blueLightDark : blueLight;
  static Color getBackground(bool isDark) =>
      isDark ? backgroundDark : background;
}
