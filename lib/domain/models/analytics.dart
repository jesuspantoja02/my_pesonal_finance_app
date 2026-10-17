class CategoryExpenseSlice {
  const CategoryExpenseSlice({
    required this.categoryId,
    required this.categoryName,
    required this.iconCodePoint,
    required this.amountCents,
  });

  final String categoryId;
  final String categoryName;
  final int iconCodePoint;
  final int amountCents;
}

class MonthlyTrendPoint {
  const MonthlyTrendPoint({
    required this.month,
    required this.expenseCents,
    required this.incomeCents,
  });

  final DateTime month;
  final int expenseCents;
  final int incomeCents;
}
