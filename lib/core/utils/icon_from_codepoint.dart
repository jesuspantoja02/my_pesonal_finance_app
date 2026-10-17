import 'package:flutter/material.dart';

/// Resuelve iconos Material guardados como codePoint en SQLite.
/// Solo usa instancias [const] para que el release pueda hacer tree-shake.
IconData iconFromCodePoint(int codePoint) {
  return _iconsByCodePoint[codePoint] ?? Icons.category_outlined;
}

const List<IconData> _knownIcons = [
  Icons.restaurant,
  Icons.directions_car,
  Icons.home,
  Icons.favorite,
  Icons.movie,
  Icons.checkroom,
  Icons.school,
  Icons.receipt_long,
  Icons.subscriptions,
  Icons.spa,
  Icons.card_giftcard,
  Icons.pets,
  Icons.work,
  Icons.savings,
  Icons.category_outlined,
  Icons.payments_outlined,
  Icons.account_balance_wallet_outlined,
  Icons.shopping_bag_outlined,
  Icons.flight_outlined,
  Icons.local_cafe_outlined,
  Icons.sports_esports_outlined,
  Icons.fitness_center_outlined,
  Icons.phone_android_outlined,
  Icons.more_horiz,
];

final Map<int, IconData> _iconsByCodePoint = {
  for (final icon in _knownIcons) icon.codePoint: icon,
};
