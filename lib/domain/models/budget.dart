class BudgetProgress {
  const BudgetProgress({
    required this.categoryId,
    required this.categoryName,
    required this.iconCodePoint,
    required this.limitCents,
    required this.spentCents,
    required this.year,
    required this.month,
  });

  final String categoryId;
  final String categoryName;
  final int iconCodePoint;
  final int limitCents;
  final int spentCents;
  final int year;
  final int month;

  double get progress =>
      limitCents <= 0 ? 0 : (spentCents / limitCents).clamp(0, 2);

  bool get isOverBudget => spentCents > limitCents;

  int get remainingCents => limitCents - spentCents;
}
