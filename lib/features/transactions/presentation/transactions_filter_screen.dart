import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/utils/money_format.dart';
import 'package:my_personal_finance_app/core/widgets/gradient_scaffold.dart';
import 'package:my_personal_finance_app/domain/models/month_transaction_filter.dart';
import 'package:my_personal_finance_app/features/transactions/presentation/transaction_editor.dart';
import 'package:my_personal_finance_app/features/transactions/presentation/widgets/transaction_tile.dart';

class TransactionsFilterScreen extends ConsumerWidget {
  const TransactionsFilterScreen({
    super.key,
    required this.month,
    required this.isIncome,
  });

  final DateTime month;
  final bool isIncome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
    final filter = MonthTransactionFilter(month: month, isIncome: isIncome);
    final transactions =
        ref.watch(monthFilteredTransactionsProvider(filter)).valueOrNull ?? [];
    final monthLabel = DateFormat.yMMMM('es').format(month);
    final accent = isIncome ? AppColors.income : AppColors.expense;
    final title = isIncome ? 'Ingresos' : 'Gastos';
    final totalCents = transactions.fold<int>(
      0,
      (sum, tx) => sum + tx.amountCents,
    );

    return GradientScaffold(
      appBar: AppBar(
        title: Text('$title · $monthLabel'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: FadeInDown(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.isFinanceDark
                      ? accent.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accent.withValues(alpha: context.isFinanceDark ? 0.5 : 0.75),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                        color: accent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total del mes',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: context.financeMuted,
                                  ),
                            ),
                            Text(
                              MoneyFormat.format(totalCents, currencyCode: currency),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: accent,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${transactions.length} mov.',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: context.financeMuted,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No hay $title en $monthLabel.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: context.financeMuted,
                            ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: 30 * (index % 10)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TransactionTile(
                            transaction: tx,
                            currencyCode: currency,
                            onTap: () => openTransactionEditor(context, transaction: tx),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

void openTransactionsFilterScreen(
  BuildContext context, {
  required DateTime month,
  required bool isIncome,
}) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => TransactionsFilterScreen(
        month: month,
        isIncome: isIncome,
      ),
    ),
  );
}
