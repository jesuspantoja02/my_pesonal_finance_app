import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/layout/main_shell_metrics.dart';
import 'package:my_personal_finance_app/core/motion/fade_slide_in.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/ui/app_empty_state.dart';
import 'package:my_personal_finance_app/core/utils/money_format.dart';
import 'package:my_personal_finance_app/core/widgets/glass_card.dart';
import 'package:my_personal_finance_app/core/widgets/gradient_glass_card.dart';
import 'package:my_personal_finance_app/features/dashboard/presentation/widgets/budget_overview_section.dart';
import 'package:my_personal_finance_app/features/dashboard/presentation/widgets/insights_preview_section.dart';
import 'package:my_personal_finance_app/features/transactions/presentation/transaction_editor.dart';
import 'package:my_personal_finance_app/features/transactions/presentation/transactions_filter_screen.dart';
import 'package:my_personal_finance_app/features/transactions/presentation/widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency =
        ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
    final total = ref.watch(totalBalanceProvider);
    final summary = ref.watch(monthlySummaryProvider).valueOrNull;
    final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
    final month = ref.watch(selectedMonthProvider);
    final monthLabel = DateFormat.yMMMM('es').format(month);
    final user = ref.watch(currentAuthUserProvider).valueOrNull;
    final greetingName = user?.firstName ?? '';
    final bottomPadding = MainShellMetrics.contentBottomPadding(context);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FadeSlideIn(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greetingName.isEmpty ? 'Hola' : 'Hola, $greetingName',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tu resumen financiero de hoy',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.financeMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: GradientGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance total',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: context.financeMuted,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        MoneyFormat.format(total, currencyCode: currency),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _StatChip(
                            label: 'Ingresos',
                            value: MoneyFormat.format(
                              summary?.incomeCents ?? 0,
                              currencyCode: currency,
                            ),
                            color: AppColors.income,
                            onTap: () => openTransactionsFilterScreen(
                              context,
                              month: month,
                              isIncome: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            label: 'Gastos',
                            value: MoneyFormat.format(
                              summary?.expenseCents ?? 0,
                              currencyCode: currency,
                            ),
                            color: AppColors.expense,
                            onTap: () => openTransactionsFilterScreen(
                              context,
                              month: month,
                              isIncome: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        toBeginningOfSentenceCase(monthLabel) ?? monthLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.financeCardFill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.financeSubtleBorder),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              ref.read(selectedMonthProvider.notifier).state =
                                  DateTime(month.year, month.month - 1);
                            },
                            icon: Icon(Icons.chevron_left, color: context.financeIcon),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              ref.read(selectedMonthProvider.notifier).state =
                                  DateTime(month.year, month.month + 1);
                            },
                            icon: Icon(Icons.chevron_right, color: context.financeIcon),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: GlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Neto del mes',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: context.financeMuted),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              MoneyFormat.format(
                                summary?.netCents ?? 0,
                                currencyCode: currency,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        (summary?.netCents ?? 0) >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: (summary?.netCents ?? 0) >= 0
                            ? AppColors.income
                            : AppColors.expense,
                        size: 36,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: InsightsPreviewSection()),
          const SliverToBoxAdapter(child: BudgetOverviewSection()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Últimos movimientos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          if (transactions.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Sin movimientos aún',
                  message: 'Pulsa «Nuevo movimiento» para registrar tu primer gasto o ingreso.',
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tx = transactions[index];
                  return FadeSlideIn(
                    delay: Duration(milliseconds: 40 * index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: TransactionTile(
                        transaction: tx,
                        currencyCode: currency,
                        onTap: () => openTransactionEditor(context, transaction: tx),
                      ),
                    ),
                  );
                },
                childCount: transactions.length.clamp(0, 5),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = !context.isFinanceDark;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.92)
                  : color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: isLight ? 0.72 : 0.48),
                width: 1.5,
              ),
              boxShadow: isLight
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: color.withValues(alpha: 0.9),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
