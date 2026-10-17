import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/constants/peruvian_banks.dart';
import 'package:my_personal_finance_app/core/constants/peruvian_digital_wallets.dart';

/// Marco de billetera: muestra tu PNG si existe en assets/wallets/.
class WalletBrandBadge extends StatelessWidget {
  const WalletBrandBadge({
    super.key,
    required this.walletId,
    this.size = 48,
  });

  final String? walletId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final wallet = PeruvianDigitalWallets.byId(walletId) ??
        PeruvianDigitalWallets.byId('otro')!;

    return _BrandImageBadge(
      size: size,
      assetPath: wallet.assetPath,
      brandColor: wallet.brandColor,
    );
  }
}

/// Marco de banco: muestra tu PNG si existe en assets/banks/.
class BankBrandBadge extends StatelessWidget {
  const BankBrandBadge({
    super.key,
    required this.bankId,
    this.size = 48,
  });

  final String? bankId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bank = PeruvianBanks.byId(bankId) ?? PeruvianBanks.byId('otro')!;

    return _BrandImageBadge(
      size: size,
      assetPath: bank.assetPath,
      brandColor: bank.brandColor,
    );
  }
}

class _BrandImageBadge extends StatelessWidget {
  const _BrandImageBadge({
    required this.size,
    required this.assetPath,
    required this.brandColor,
  });

  final double size;
  final String assetPath;
  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.28);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: brandColor.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        // Sin imagen: solo el marco blanco vacío (tú pones el PNG).
        errorBuilder: (context, error, stackTrace) => const ColoredBox(
          color: Color(0xFFF1F5F9),
        ),
      ),
    );
  }
}
