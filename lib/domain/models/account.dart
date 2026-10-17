import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/constants/peruvian_banks.dart';
import 'package:my_personal_finance_app/core/constants/peruvian_digital_wallets.dart';
import 'package:my_personal_finance_app/domain/models/card_kind.dart';
import 'package:my_personal_finance_app/domain/models/card_network.dart';

/// Categorías de cuenta en la app (se guardan en SQLite como texto).
enum AccountType {
  cash,
  digitalWallet,
  card,
  /// Cuentas creadas antes del agrupamiento por categoría.
  bank,
}

extension AccountTypeDisplay on AccountType {
  static const _legacyWalletTypeKeys = {
    'yape',
    'plin',
    'tunki',
    'agora',
    'sip',
    'bim',
  };

  /// Tipos que el usuario puede elegir al crear o editar una cuenta.
  static const List<AccountType> selectable = [
    AccountType.cash,
    AccountType.digitalWallet,
    AccountType.card,
  ];

  String get label => switch (this) {
        AccountType.cash => 'Efectivo',
        AccountType.digitalWallet => 'Billetera digital',
        AccountType.card => 'Tarjeta',
        AccountType.bank => 'Cuenta bancaria',
      };

  String get storageKey => switch (this) {
        AccountType.cash => 'cash',
        AccountType.digitalWallet => 'digital_wallet',
        AccountType.card => 'card',
        AccountType.bank => 'bank',
      };

  IconData iconForProvider(String? providerId) => switch (this) {
        AccountType.cash => Icons.payments_outlined,
        AccountType.digitalWallet =>
          PeruvianDigitalWallets.iconForId(providerId),
        AccountType.card => Icons.credit_card,
        AccountType.bank => Icons.account_balance_outlined,
      };

  bool get needsProvider =>
      this == AccountType.digitalWallet || this == AccountType.card;

  bool get isBank => this == AccountType.bank;

  static AccountType fromStorage(String value) {
    if (_legacyWalletTypeKeys.contains(value)) {
      return AccountType.digitalWallet;
    }
    return AccountType.values.firstWhere(
      (e) => e.storageKey == value || e.name == value,
      orElse: () => AccountType.cash,
    );
  }

  /// Normaliza filas antiguas (p. ej. `type: yape` sin `bank_id`).
  static ({AccountType type, String? providerId}) normalizeFromStorage({
    required String typeKey,
    String? providerId,
  }) {
    if (_legacyWalletTypeKeys.contains(typeKey)) {
      return (
        type: AccountType.digitalWallet,
        providerId: providerId ?? typeKey,
      );
    }
    final type = fromStorage(typeKey);
    return (type: type, providerId: providerId);
  }
}

class AccountModel {
  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalanceCents,
    required this.colorValue,
    this.bankId,
    this.cardKind,
    this.cardNetwork,
    this.balanceCents = 0,
  });

  final String id;
  final String name;
  final AccountType type;
  final int initialBalanceCents;
  final int colorValue;

  /// Billetera (`yape`, `plin`, …) o banco emisor de la tarjeta (`bcp`, …).
  final String? bankId;
  final CardKind? cardKind;
  final CardNetwork? cardNetwork;
  final int balanceCents;

  bool get isDefaultCash =>
      type == AccountType.cash && name == kDefaultCashAccountName;

  Color get color => Color(colorValue);

  String get typeSubtitle {
    return switch (type) {
      AccountType.cash => 'Efectivo',
      AccountType.digitalWallet => _walletSubtitle,
      AccountType.card => _cardSubtitle,
      AccountType.bank => _legacyBankSubtitle,
    };
  }

  String get _walletSubtitle {
    final name = PeruvianDigitalWallets.nameForId(bankId);
    if (name != null) return 'Billetera digital · $name';
    return 'Billetera digital';
  }

  String get _cardSubtitle {
    final bankName = PeruvianBanks.nameForId(bankId);
    final kind = cardKind?.label ?? CardKind.debit.label;
    final network = cardNetwork?.label;
    final parts = <String>[
      ?network,
      kind,
      ?bankName,
    ];
    return parts.join(' · ');
  }

  String get _legacyBankSubtitle {
    final name = PeruvianBanks.nameForId(bankId);
    if (name != null) return 'Cuenta bancaria · $name';
    return 'Cuenta bancaria';
  }

  IconData get listIcon => type.iconForProvider(bankId);

  AccountModel copyWith({
    int? balanceCents,
    String? bankId,
    CardKind? cardKind,
    CardNetwork? cardNetwork,
  }) {
    return AccountModel(
      id: id,
      name: name,
      type: type,
      initialBalanceCents: initialBalanceCents,
      colorValue: colorValue,
      bankId: bankId ?? this.bankId,
      cardKind: cardKind ?? this.cardKind,
      cardNetwork: cardNetwork ?? this.cardNetwork,
      balanceCents: balanceCents ?? this.balanceCents,
    );
  }
}
