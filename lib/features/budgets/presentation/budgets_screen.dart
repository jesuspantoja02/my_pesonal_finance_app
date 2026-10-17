import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/utils/icon_from_codepoint.dart';
import 'package:my_personal_finance_app/core/utils/money_format.dart';
import 'package:my_personal_finance_app/core/widgets/glass_card.dart';
import 'package:my_personal_finance_app/core/widgets/gradient_scaffold.dart';
import 'package:my_personal_finance_app/domain/models/category.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final currency = ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
    final categories =
        ref.watch(categoriesProvider).valueOrNull?.where((c) => c.isExpense).toList() ??
            [];
    final progress = ref.watch(budgetProgressProvider).valueOrNull ?? [];
    final progressByCategory = {for (final p in progress) p.categoryId: p};

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Límite mensual por categoría de gasto',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.financeMuted,
                  ),
            ),
            const SizedBox(height: 16),
            ...categories.map((category) {
              final item = progressByCategory[category.id];
              return FadeInUp(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BudgetCategoryTile(
                    category: category,
                    currencyCode: currency,
                    month: month,
                    currentLimitCents: item?.limitCents,
                    spentCents: item?.spentCents ?? 0,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _BudgetCategoryTile extends ConsumerStatefulWidget {
  const _BudgetCategoryTile({
    required this.category,
    required this.currencyCode,
    required this.month,
    required this.spentCents,
    this.currentLimitCents,
  });

  final CategoryModel category;
  final String currencyCode;
  final DateTime month;
  final int spentCents;
  final int? currentLimitCents;

  @override
  ConsumerState<_BudgetCategoryTile> createState() =>
      _BudgetCategoryTileState();
}

class _BudgetCategoryTileState extends ConsumerState<_BudgetCategoryTile> {
  late final TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(
      text: widget.currentLimitCents != null && widget.currentLimitCents! > 0
          ? (widget.currentLimitCents! / 100).toStringAsFixed(0)
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant _BudgetCategoryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLimitCents != widget.currentLimitCents &&
        widget.currentLimitCents != null &&
        widget.currentLimitCents! > 0) {
      _limitController.text = (widget.currentLimitCents! / 100).toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cents = MoneyFormat.parseToCents(_limitController.text);
    await ref.read(financeRepositoryProvider).upsertBudget(
          categoryId: widget.category.id,
          year: widget.month.year,
          month: widget.month.month,
          limitCents: cents,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Presupuesto de ${widget.category.name} guardado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final limit = widget.currentLimitCents ?? 0;
    final progress = limit <= 0 ? 0.0 : widget.spentCents / limit;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconFromCodePoint(widget.category.iconCodePoint)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (limit > 0)
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: progress > 1
                            ? AppColors.expense
                            : AppColors.income,
                        fontWeight: FontWeight.w700,
                      ),
                ),
            ],
          ),
          if (limit > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: context.financeSubtleBorder.withValues(alpha: 0.35),
                color: progress > 1 ? AppColors.expense : AppColors.teal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Gastado: ${MoneyFormat.format(widget.spentCents, currencyCode: widget.currencyCode)} de ${MoneyFormat.format(limit, currencyCode: widget.currencyCode)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.financeMuted,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Límite (${MoneyFormat.currencySymbol(widget.currencyCode)})',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _save,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
