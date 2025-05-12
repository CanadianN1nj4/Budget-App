import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette (Calming blues and greens)
  static const Color primary = Color(0xFF4A90E2); // Calming Blue (example)
  static const Color primaryForeground = Colors.white;
  static const Color secondary = Color(
    0xFFE0F2F1,
  ); // Very light calming green/cyan tint (example)
  static const Color secondaryForeground = Color(
    0xFF004D40,
  ); // Darker green/cyan

  // Neutral Grays
  static const Color background = Color(0xFFF8F9FA); // Very light cool gray
  static const Color foreground = Color(0xFF343A40); // Dark cool gray
  static const Color card = Colors.white;
  static const Color cardForeground = Color(0xFF343A40);
  static const Color popover = Colors.white;
  static const Color popoverForeground = Color(0xFF343A40);
  static const Color muted = Color(0xFFE9ECEF); // Light cool gray
  static const Color mutedForeground = Color(0xFF6C757D); // Medium cool gray
  static const Color border = Color(
    0xFFDEE2E6,
  ); // Slightly darker cool gray border
  static const Color input = Color(
    0xFFF1F3F5,
  ); // Slightly lighter cool gray input

  // Accent Color
  static const Color accent = Color(0xFF008080); // Teal (from blueprint)
  static const Color accentForeground = Colors.white;

  // Destructive Color
  static const Color destructive = Color(0xFFDC3545); // Default red
  static const Color destructiveForeground = Colors.white;

  // Chart Colors (from globals.css)
  static const Color chart1 = Color(0xFFF47A5A); // hsl(12 76% 61%)
  static const Color chart2 = Color(0xFF4CAF50); // hsl(173 58% 39%) - approx
  static const Color chart3 = Color(0xFF2C3E50); // hsl(197 37% 24%) - approx
  static const Color chart4 = Color(0xFFFBC02D); // hsl(43 74% 66%) - approx
  static const Color chart5 = Color(0xFFF57C00); // hsl(27 87% 67%) - approx

  // MaterialColor for primarySwatch
  static MaterialColor primarySwatch = MaterialColor(primary.value, {
    50: primary.withOpacity(0.1),
    100: primary.withOpacity(0.2),
    200: primary.withOpacity(0.3),
    300: primary.withOpacity(0.4),
    400: primary.withOpacity(0.5),
    500: primary.withOpacity(0.6),
    600: primary.withOpacity(0.7),
    700: primary.withOpacity(0.8),
    800: primary.withOpacity(0.9),
    900: primary.withOpacity(1.0),
  });
}
