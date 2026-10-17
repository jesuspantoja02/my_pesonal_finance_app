import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/utils/icon_from_codepoint.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.isExpense,
  });

  final String id;
  final String name;
  final int iconCodePoint;
  final bool isExpense;

  IconData get icon => iconFromCodePoint(iconCodePoint);
}
