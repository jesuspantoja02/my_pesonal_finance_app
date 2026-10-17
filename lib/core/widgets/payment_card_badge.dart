import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/constants/peruvian_banks.dart';
import 'package:my_personal_finance_app/core/constants/peruvian_digital_wallets.dart';
import 'package:my_personal_finance_app/core/widgets/wallet_brand_badge.dart';
import 'package:my_personal_finance_app/domain/models/account.dart';
import 'package:my_personal_finance_app/domain/models/card_network.dart';

/// Mini tarjeta plástica (aspecto real) para cuentas tipo tarjeta.
class PaymentCardBadge extends StatelessWidget {
  const PaymentCardBadge({
    super.key,
    required this.network,
    this.width = 56,
    this.height = 36,
    this.showChip = true,
  });

  final CardNetwork network;
  final double width;
  final double height;
  final bool showChip;

  @override
  Widget build(BuildContext context) {
    final radius = height * 0.18;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: network.gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: network.brandColor.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: height * 0.18,
            left: width * 0.12,
            child: Container(
              width: width * 0.22,
              height: height * 0.28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8C872), Color(0xFFC9A227)],
                ),
              ),
            ),
          ),
          if (network == CardNetwork.mastercard)
            Positioned(
              right: width * 0.1,
              bottom: height * 0.18,
              child: SizedBox(
                width: width * 0.38,
                height: height * 0.42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: const Alignment(-0.35, 0),
                      child: Container(
                        width: height * 0.38,
                        height: height * 0.38,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEB001B),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0.35, 0),
                      child: Container(
                        width: height * 0.38,
                        height: height * 0.38,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF79E1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Positioned(
              right: width * 0.1,
              bottom: height * 0.14,
              child: Text(
                network.shortLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w800,
                  fontSize: height * 0.28,
                  letterSpacing: network == CardNetwork.visa ? 1.2 : 0.4,
                  fontStyle: network == CardNetwork.visa
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compat: usa el badge de marca de billetera.
class WalletBadge extends StatelessWidget {
  const WalletBadge({
    super.key,
    required this.walletId,
    this.size = 48,
  });

  final String? walletId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return WalletBrandBadge(walletId: walletId, size: size);
  }
}

/// Avatar unificado: tarjeta, billetera o ícono genérico.
class AccountLeadingVisual extends StatelessWidget {
  const AccountLeadingVisual({
    super.key,
    required this.account,
    this.size = 48,
  });

  final AccountModel account;
  final double size;

  String? _resolveWalletId() {
    if (PeruvianDigitalWallets.byId(account.bankId) != null) {
      return account.bankId;
    }
    final name = account.name.toLowerCase();
    for (final wallet in PeruvianDigitalWallets.all) {
      if (wallet.id == 'otro') continue;
      if (name.contains(wallet.id) ||
          name.contains(wallet.name.toLowerCase())) {
        return wallet.id;
      }
    }
    if (account.type == AccountType.digitalWallet) {
      return account.bankId ?? 'otro';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (account.type == AccountType.card && account.cardNetwork != null) {
      return PaymentCardBadge(
        network: account.cardNetwork!,
        width: size * 1.15,
        height: size * 0.72,
      );
    }

    final walletId = _resolveWalletId();
    if (walletId != null) {
      return WalletBrandBadge(walletId: walletId, size: size);
    }

    if ((account.type == AccountType.card || account.type == AccountType.bank) &&
        PeruvianBanks.byId(account.bankId) != null) {
      return BankBrandBadge(bankId: account.bankId, size: size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: account.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size * 0.33),
      ),
      child: Icon(
        account.listIcon,
        color: account.color,
        size: size * 0.5,
      ),
    );
  }
}

/// Selector visual de marca de tarjeta.
class CardNetworkPicker extends StatelessWidget {
  const CardNetworkPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CardNetwork value;
  final ValueChanged<CardNetwork> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: CardNetwork.values.map((network) {
        final selected = value == network;
        return InkWell(
          onTap: () => onChanged(network),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? network.brandColor
                    : Theme.of(context).dividerColor.withValues(alpha: 0.4),
                width: selected ? 2 : 1,
              ),
              color: selected
                  ? network.brandColor.withValues(alpha: 0.08)
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PaymentCardBadge(network: network, width: 52, height: 34),
                const SizedBox(width: 10),
                Text(
                  network.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? network.brandColor : null,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
