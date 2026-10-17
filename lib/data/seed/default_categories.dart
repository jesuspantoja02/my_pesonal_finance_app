import 'package:flutter/material.dart';

class DefaultCategoryDefinition {
  DefaultCategoryDefinition({
    required this.name,
    required this.iconCodePoint,
    required this.isExpense,
  });

  final String name;
  final int iconCodePoint;
  final bool isExpense;
}

/// Categorías por defecto (gasto e ingreso). Se insertan si no existen por nombre.
final kDefaultCategoryDefinitions = [
  DefaultCategoryDefinition(
    name: 'Comida',
    iconCodePoint: Icons.restaurant.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Transporte',
    iconCodePoint: Icons.directions_car.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Hogar',
    iconCodePoint: Icons.home.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Salud',
    iconCodePoint: Icons.favorite.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Ocio',
    iconCodePoint: Icons.movie.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Ropa',
    iconCodePoint: Icons.checkroom.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Educación',
    iconCodePoint: Icons.school.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Servicios',
    iconCodePoint: Icons.receipt_long.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Suscripciones',
    iconCodePoint: Icons.subscriptions.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Cuidado personal',
    iconCodePoint: Icons.spa.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Regalos',
    iconCodePoint: Icons.card_giftcard.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Mascotas',
    iconCodePoint: Icons.pets.codePoint,
    isExpense: true,
  ),
  DefaultCategoryDefinition(
    name: 'Salario',
    iconCodePoint: Icons.work.codePoint,
    isExpense: false,
  ),
  DefaultCategoryDefinition(
    name: 'Otros ingresos',
    iconCodePoint: Icons.savings.codePoint,
    isExpense: false,
  ),
];
