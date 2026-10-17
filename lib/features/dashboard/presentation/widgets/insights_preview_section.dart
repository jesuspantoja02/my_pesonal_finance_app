import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/widgets/glass_card.dart';
import 'package:my_personal_finance_app/core/widgets/section_header.dart';
import 'package:my_personal_finance_app/features/insights/presentation/insights_screen.dart';
import 'package:my_personal_finance_app/features/insights/presentation/widgets/expense_pie_chart.dart';

class InsightsPreviewSection extends ConsumerWidget {
  const InsightsPreviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
    final slices = ref.watch(categoryExpensesProvider).valueOrNull ?? [];
    if (slices.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SectionHeader(
          title: 'Análisis del mes',
          subtitle: 'Distribución de tus gastos',
          trailing: TextButton(
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) => const InsightsScreen(),
                ),
              );
            },
            child: const Text('Ver más'),
          ),
        ),
        FadeInUp(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GlassCard(
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) => const InsightsScreen(),
                  ),
                );
              },
              child: ExpensePieChart(
                slices: slices,
                currencyCode: currency,
                compact: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
