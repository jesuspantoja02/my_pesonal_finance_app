import 'package:flutter/material.dart';

/// Marca / red de la tarjeta (cómo se ve en una tarjeta real).
enum CardNetwork {
  visa,
  mastercard,
  amex,
  diners,
  other;

  String get label => switch (this) {
        CardNetwork.visa => 'Visa',
        CardNetwork.mastercard => 'Mastercard',
        CardNetwork.amex => 'American Express',
        CardNetwork.diners => 'Diners Club',
        CardNetwork.other => 'Otra',
      };

  String get shortLabel => switch (this) {
        CardNetwork.visa => 'VISA',
        CardNetwork.mastercard => 'MC',
        CardNetwork.amex => 'AMEX',
        CardNetwork.diners => 'DINERS',
        CardNetwork.other => 'CARD',
      };

  String get storageKey => name;

  /// Color de acento asociado a la marca (para listas / chips).
  Color get brandColor => switch (this) {
        CardNetwork.visa => const Color(0xFF1A1F71),
        CardNetwork.mastercard => const Color(0xFFEB001B),
        CardNetwork.amex => const Color(0xFF006FCF),
        CardNetwork.diners => const Color(0xFF004B87),
        CardNetwork.other => const Color(0xFF0F766E),
      };

  List<Color> get gradientColors => switch (this) {
        CardNetwork.visa => const [Color(0xFF1A1F71), Color(0xFF0A3D91)],
        CardNetwork.mastercard => const [Color(0xFF1F1F1F), Color(0xFF3D3D3D)],
        CardNetwork.amex => const [Color(0xFF006FCF), Color(0xFF004B8D)],
        CardNetwork.diners => const [Color(0xFF004B87), Color(0xFF002B4D)],
        CardNetwork.other => const [Color(0xFF0F766E), Color(0xFF115E59)],
      };

  static CardNetwork fromStorage(String? value) {
    if (value == null || value.isEmpty) return CardNetwork.visa;
    for (final network in CardNetwork.values) {
      if (network.storageKey == value) return network;
    }
    return CardNetwork.visa;
  }
}
