import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/layout/main_shell_metrics.dart';
import 'package:my_personal_finance_app/core/motion/fade_slide_in.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/ui/app_empty_state.dart';
import 'package:my_personal_finance_app/core/ui/app_screen_header.dart';
import 'package:my_personal_finance_app/features/transactions/presentation/transaction_editor.dart';
import 'package:my_personal_finance_app/features/transactions/presentation/widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency =
        ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
    final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
    final bottomPadding = MainShellMetrics.contentBottomPadding(context);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppScreenHeader(
            title: 'Movimientos',
            subtitle: 'Historial de este mes',
          ),
          Expanded(
            child: transactions.isEmpty
                ? const AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Aún no hay movimientos',
                    message:
                        'Usa «Nuevo movimiento» para registrar un gasto o un ingreso.',
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPadding),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return FadeSlideIn(
                        delay: Duration(milliseconds: 28 * (index.clamp(0, 10))),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TransactionTile(
                            transaction: tx,
                            currencyCode: currency,
                            onTap: () => openTransactionEditor(
                              context,
                              transaction: tx,
                            ),
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
