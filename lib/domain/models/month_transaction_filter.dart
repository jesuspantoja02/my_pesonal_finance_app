class MonthTransactionFilter {
  const MonthTransactionFilter({
    required this.month,
    required this.isIncome,
  });

  final DateTime month;
  final bool isIncome;

  @override
  bool operator ==(Object other) {
    return other is MonthTransactionFilter &&
        month.year == other.month.year &&
        month.month == other.month.month &&
        isIncome == other.isIncome;
  }

  @override
  int get hashCode => Object.hash(month.year, month.month, isIncome);
}
