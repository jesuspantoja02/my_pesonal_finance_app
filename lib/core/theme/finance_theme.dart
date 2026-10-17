import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';

extension FinanceTheme on BuildContext {
  bool get isFinanceDark => Theme.of(this).brightness == Brightness.dark;

  Color get financeMuted =>
      isFinanceDark ? AppColors.textMuted : AppColors.textMutedLight;

  Color get financeBorder =>
      isFinanceDark
          ? Colors.white.withValues(alpha: 0.14)
          : AppColors.borderLight;

  Color get financeCardFill =>
      isFinanceDark
          ? Colors.white.withValues(alpha: 0.08)
          : AppColors.surfaceCardLight.withValues(alpha: 0.94);

  Color get financeOnSurface => Theme.of(this).colorScheme.onSurface;

  Color get financeIcon => financeOnSurface.withValues(alpha: 0.88);

  Color get financeChevron => financeMuted;

  Color get financePieSectionBorder =>
      isFinanceDark ? AppColors.surfaceDark : Colors.white;

  Color get financeSubtleBorder =>
      isFinanceDark
          ? Colors.white.withValues(alpha: 0.12)
          : AppColors.borderLight;

  Color get financeChartGridLine =>
      isFinanceDark
          ? Colors.white.withValues(alpha: 0.08)
          : AppColors.borderLight.withValues(alpha: 0.9);
}
