import 'package:flutter/material.dart';

abstract final class AppColors {
  // Accent — indigo, sophisticated and modern
  static const accent = Color(0xFF6366F1);
  static const accentLight = Color(0xFF818CF8);
  static const accentSubtle = Color(0x1A6366F1);

  // Dark palette
  static const darkBackground = Color(0xFF0A0A0B);
  static const darkSurface = Color(0xFF131315);
  static const darkSurfaceVariant = Color(0xFF1C1C1F);
  static const darkBorder = Color(0xFF2A2A2D);
  static const darkBorderSubtle = Color(0xFF1F1F22);

  // Light palette
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF4F4F5);
  static const lightBorder = Color(0xFFE4E4E7);
  static const lightBorderSubtle = Color(0xFFF1F1F3);

  // Semantic — dark
  static const darkTextPrimary = Color(0xFFF5F5F7);
  static const darkTextSecondary = Color(0xFFA1A1AA);
  static const darkTextTertiary = Color(0xFF71717A);

  // Semantic — light
  static const lightTextPrimary = Color(0xFF18181B);
  static const lightTextSecondary = Color(0xFF52525B);
  static const lightTextTertiary = Color(0xFFA1A1AA);

  // Document type badge colors
  static const pdfColor = Color(0xFFEF4444);
  static const docxColor = Color(0xFF3B82F6);
  static const pptxColor = Color(0xFFF97316);
  static const xlsxColor = Color(0xFF22C55E);

  // Status
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
}
