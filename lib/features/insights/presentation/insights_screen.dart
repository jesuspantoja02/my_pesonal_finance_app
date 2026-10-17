import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/widgets/glass_card.dart';
import 'package:my_personal_finance_app/core/widgets/gradient_scaffold.dart';
import 'package:my_personal_finance_app/features/insights/presentation/widgets/expense_pie_chart.dart';
import 'package:my_personal_finance_app/features/insights/presentation/widgets/trend_bar_chart.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
    final month = ref.watch(selectedMonthProvider);
    final monthLabel = DateFormat.yMMMM('es').format(month);
    final slices = ref.watch(categoryExpensesProvider).valueOrNull ?? [];
    final trend = ref.watch(monthlyTrendProvider).valueOrNull ?? [];

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Análisis'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            FadeInDown(
              child: Text(
                'Tus finanzas en gráficos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              monthLabel,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.financeMuted,
                  ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gastos por categoría',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Solo movimientos de gasto del mes seleccionado',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.expense.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ExpensePieChart(
                      slices: slices,
                      currencyCode: currency,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tendencia (6 meses)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _LegendDot(color: AppColors.expense, label: 'Gastos'),
                        const SizedBox(width: 16),
                        _LegendDot(color: AppColors.income, label: 'Ingresos'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TrendBarChart(points: trend),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
