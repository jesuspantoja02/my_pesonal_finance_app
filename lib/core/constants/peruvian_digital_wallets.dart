import 'package:flutter/material.dart';

class PeruvianDigitalWallet {
  const PeruvianDigitalWallet({
    required this.id,
    required this.name,
    required this.icon,
    required this.brandColor,
    this.gradientColors,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color brandColor;
  final List<Color>? gradientColors;

  List<Color> get colors =>
      gradientColors ?? [brandColor, brandColor.withValues(alpha: 0.75)];

  /// Logo real empaquetado en la app.
  String get assetPath => 'assets/wallets/$id.png';
}

abstract final class PeruvianDigitalWallets {
  /// Solo billeteras soportadas en la app.
  static const List<PeruvianDigitalWallet> all = [
    PeruvianDigitalWallet(
      id: 'yape',
      name: 'Yape',
      icon: Icons.qr_code_2_rounded,
      brandColor: Color(0xFF6F2C91),
      gradientColors: [Color(0xFF6F2C91), Color(0xFF9B4DFF)],
    ),
    PeruvianDigitalWallet(
      id: 'plin',
      name: 'Plin',
      icon: Icons.phone_android_rounded,
      brandColor: Color(0xFF00A3E0),
      gradientColors: [Color(0xFF0082B3), Color(0xFF00C2FF)],
    ),
    PeruvianDigitalWallet(
      id: 'tunki',
      name: 'Tunki',
      icon: Icons.account_balance_wallet_outlined,
      brandColor: Color(0xFF00A86B),
      gradientColors: [Color(0xFF007A4D), Color(0xFF00C97A)],
    ),
    PeruvianDigitalWallet(
      id: 'agora',
      name: 'Agora',
      icon: Icons.storefront_outlined,
      brandColor: Color(0xFF00B37A),
      gradientColors: [Color(0xFF008F62), Color(0xFF2DD4A8)],
    ),
    PeruvianDigitalWallet(
      id: 'sip',
      name: 'SIP',
      icon: Icons.account_balance_wallet_rounded,
      brandColor: Color(0xFF0072C6),
      gradientColors: [Color(0xFF005A9E), Color(0xFF2B9BFF)],
    ),
    PeruvianDigitalWallet(
      id: 'bim',
      name: 'BIM',
      icon: Icons.account_balance_wallet_outlined,
      brandColor: Color(0xFF0F766E),
      gradientColors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
    ),
    PeruvianDigitalWallet(
      id: 'otro',
      name: 'Otra billetera digital',
      icon: Icons.payments_outlined,
      brandColor: Color(0xFF0F766E),
      gradientColors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
    ),
  ];

  static PeruvianDigitalWallet? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final wallet in all) {
      if (wallet.id == id) return wallet;
    }
    return null;
  }

  static String? nameForId(String? id) => byId(id)?.name;

  static IconData iconForId(String? id) =>
      byId(id)?.icon ?? Icons.account_balance_wallet_outlined;

  static Color colorForId(String? id) =>
      byId(id)?.brandColor ?? const Color(0xFF0F766E);
}
