class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amountCents,
    required this.isIncome,
    required this.date,
    required this.note,
    required this.createdAt,
    this.accountName,
    this.categoryName,
    this.categoryIconCodePoint,
  });

  final String id;
  final String accountId;
  final String categoryId;
  final int amountCents;
  final bool isIncome;
  final DateTime date;
  final String note;
  final DateTime createdAt;
  final String? accountName;
  final String? categoryName;
  final int? categoryIconCodePoint;
}

class MonthlySummary {
  const MonthlySummary({
    required this.incomeCents,
    required this.expenseCents,
    required this.month,
  });

  final int incomeCents;
  final int expenseCents;
  final DateTime month;

  int get netCents => incomeCents - expenseCents;
}
