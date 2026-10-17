import 'package:flutter/material.dart';

abstract final class ChartPalette {
  /// Gastos por categoría (sin verdes de ingreso).
  static const expenseSlices = [
    Color(0xFFF87171),
    Color(0xFF6366F1),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFFFB7185),
    Color(0xFF38BDF8),
    Color(0xFFA78BFA),
    Color(0xFFEA580C),
    Color(0xFF7C3AED),
  ];

  static const slices = expenseSlices;

  static Color forIndex(int index) => expenseSlices[index % expenseSlices.length];

  static Color forCategoryId(String categoryId, int sortedIndex) {
    if (categoryId == 'otros') {
      return const Color(0xFF94A3B8);
    }
    final hash = categoryId.hashCode.abs();
    return expenseSlices[(hash + sortedIndex) % expenseSlices.length];
  }
}
