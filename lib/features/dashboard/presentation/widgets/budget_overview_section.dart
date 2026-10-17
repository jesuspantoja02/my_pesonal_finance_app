import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/utils/icon_from_codepoint.dart';
import 'package:my_personal_finance_app/core/utils/money_format.dart';
import 'package:my_personal_finance_app/core/widgets/glass_card.dart';
import 'package:my_personal_finance_app/features/budgets/presentation/budgets_screen.dart';

class BudgetOverviewSection extends ConsumerWidget {
  const BudgetOverviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
    final items = ref.watch(budgetProgressProvider).valueOrNull ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final top = items.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Presupuestos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (context) => const BudgetsScreen(),
                    ),
                  );
                },
                child: const Text('Ver todos'),
              ),
            ],
          ),
        ),
        ...top.map(
          (item) => FadeInUp(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(iconFromCodePoint(item.iconCodePoint), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.categoryName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        Text(
                          MoneyFormat.format(item.spentCents, currencyCode: currency),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: item.isOverBudget
                                    ? AppColors.expense
                                    : AppColors.income,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: item.progress.clamp(0, 1),
                        minHeight: 6,
                        backgroundColor: context.financeSubtleBorder.withValues(alpha: 0.35),
                        color: item.isOverBudget ? AppColors.expense : AppColors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
