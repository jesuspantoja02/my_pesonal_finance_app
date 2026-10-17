import 'package:flutter/material.dart';

abstract final class AppColors {
  static const tealDark = Color(0xFF0F766E);
  static const teal = Color(0xFF14B8A6);
  static const emerald = Color(0xFF10B981);
  static const mint = Color(0xFF6EE7B7);
  static const surfaceDark = Color(0xFF0B1220);
  static const surfaceCard = Color(0xFF111827);
  static const surfaceElevated = Color(0xFF1F2937);
  static const income = Color(0xFF34D399);
  static const expense = Color(0xFFF87171);
  static const textMuted = Color(0xFF9CA3AF);

  static const surfaceLight = Color(0xFFF8FAFC);
  static const surfaceCardLight = Color(0xFFFFFFFF);
  static const surfaceElevatedLight = Color(0xFFE2E8F0);
  static const textMutedLight = Color(0xFF64748B);
  static const textStrongLight = Color(0xFF334155);
  static const borderLight = Color(0xFFCBD5E1);
  static const chipSelectedLight = Color(0xFF0F766E);

  static const homeGradient = [
    Color(0xFF042F2E),
    Color(0xFF0B1220),
    Color(0xFF111827),
  ];

  static const homeGradientLight = [
    Color(0xFFCCFBF1),
    Color(0xFFF0FDFA),
    Color(0xFFF8FAFC),
  ];

  static const splashGradient = [
    Color(0xFF0D9488),
    Color(0xFF059669),
    Color(0xFF047857),
  ];

  static List<Color> homeGradientFor(Brightness brightness) {
    return brightness == Brightness.dark ? homeGradient : homeGradientLight;
  }
}
