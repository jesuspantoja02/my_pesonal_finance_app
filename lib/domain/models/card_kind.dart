enum CardKind {
  debit,
  credit,
  prepaid;

  String get label => switch (this) {
        CardKind.debit => 'Débito',
        CardKind.credit => 'Crédito',
        CardKind.prepaid => 'Prepago',
      };

  String get storageKey => name;

  static CardKind fromStorage(String? value) {
    if (value == null || value.isEmpty) return CardKind.debit;
    for (final kind in CardKind.values) {
      if (kind.storageKey == value) return kind;
    }
    return CardKind.debit;
  }
}
