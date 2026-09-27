import 'package:flutter/material.dart';

/// Centralized Color Palette for the App
/// Use these colors throughout the app to maintain consistency.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // === Primary Brand Colors ===
  static const Color primary = Color(0xFF0E4677);       // Dark Blue (Main Brand / Buttons)
  static const Color secondary = Color(0xFFA7D8F0);     // Celestial Blue (Secondary Accent)
  static const Color background = Color(0xFFFFF6E5);    // Stardust Cream (App Background)
  
  // === Neutral Colors (Text, Borders, Backgrounds) ===
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color black87 = Colors.black87;          // Slightly lighter black for text
  static const Color textPrimary = Color(0xFF1A3665);   // Dark Navy Blue (For Headings)
  static const Color textSecondary = Colors.grey;       // Grey (For Subtitles / Descriptions)
  static const Color border = Color(0xFFE0E0E0);        // Light Grey (For TextFields and Borders)
  
  // === State Colors (Success, Error, Warning) ===
  static const Color success = Colors.green;            // Success Toasts / Validations
  static const Color error = Colors.red;                // Error Toasts / Invalid Inputs
  static const Color warning = Colors.orange;           // Warnings
}
