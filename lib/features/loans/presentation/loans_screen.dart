import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/layout/main_shell_metrics.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/services/loan_notification_service.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/ui/app_empty_state.dart';
import 'package:my_personal_finance_app/core/ui/app_screen_header.dart';
import 'package:my_personal_finance_app/core/utils/money_format.dart';
import 'package:my_personal_finance_app/core/widgets/glass_card.dart';
import 'package:my_personal_finance_app/domain/models/loan.dart';
import 'package:my_personal_finance_app/features/loans/presentation/widgets/add_loan_sheet.dart';

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loans = ref.watch(loansProvider).valueOrNull ?? [];
    final currency =
        ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
    final bottomPadding = MainShellMetrics.contentBottomPadding(context);

    final active = loans.where((l) => !l.isSettled).toList();
    final settled = loans.where((l) => l.isSettled).toList();
    final owedByMe = active
        .where((l) => l.direction == LoanDirection.borrowed)
        .fold<int>(0, (sum, l) => sum + l.amountCents);
    final owedToMe = active
        .where((l) => l.direction == LoanDirection.lent)
        .fold<int>(0, (sum, l) => sum + l.amountCents);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const AppScreenHeader(
            title: 'Préstamos',
            subtitle: 'Lo que debes y lo que te deben',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryChip(
                    label: 'Debo',
                    value: MoneyFormat.format(owedByMe, currencyCode: currency),
                    color: AppColors.expense,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryChip(
                    label: 'Me deben',
                    value: MoneyFormat.format(owedToMe, currencyCode: currency),
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: loans.isEmpty
                ? const AppEmptyState(
                    icon: Icons.handshake_outlined,
                    title: 'Sin préstamos',
                    message:
                        'Registra si te prestaron o si prestaste dinero, con fecha de pago y aviso.',
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                    children: [
                      ...active.asMap().entries.map((entry) {
                        return FadeInUp(
                          delay: Duration(milliseconds: 40 * entry.key),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _LoanTile(
                              loan: entry.value,
                              currency: currency,
                              onTap: () => showAddLoanSheet(
                                context,
                                ref,
                                loan: entry.value,
                              ),
                              onToggleSettled: () => _setSettled(
                                ref,
                                entry.value,
                                settled: true,
                              ),
                              onDelete: () => _confirmDelete(
                                context,
                                ref,
                                entry.value,
                              ),
                            ),
                          ),
                        );
                      }),
                      if (settled.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Saldados',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: context.financeMuted,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        ...settled.map(
                          (loan) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _LoanTile(
                              loan: loan,
                              currency: currency,
                              onTap: () =>
                                  showAddLoanSheet(context, ref, loan: loan),
                              onToggleSettled: () => _setSettled(
                                ref,
                                loan,
                                settled: false,
                              ),
                              onDelete: () =>
                                  _confirmDelete(context, ref, loan),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _setSettled(
    WidgetRef ref,
    LoanModel loan, {
    required bool settled,
  }) async {
    await ref
        .read(financeRepositoryProvider)
        .setLoanSettled(loan.id, settled: settled);
    if (settled) {
      await LoanNotificationService.instance.cancel(loan.id);
    } else if (loan.notifyEnabled) {
      final currency =
          ref.read(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
      final amount =
          MoneyFormat.format(loan.amountCents, currencyCode: currency);
      await LoanNotificationService.instance.scheduleDueReminder(
        loanId: loan.id,
        title: loan.direction == LoanDirection.borrowed
            ? 'Hoy debes pagar un préstamo'
            : 'Hoy te deben pagar',
        body: loan.direction == LoanDirection.borrowed
            ? 'Paga $amount a ${loan.counterpartyName}'
            : '${loan.counterpartyName} te debe $amount',
        dueDate: loan.dueDate,
        hour: loan.notifyHour,
        minute: loan.notifyMinute,
        repeatHourly: loan.notifyRepeatHourly,
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LoanModel loan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar préstamo?'),
        content: Text(
          'Se eliminará el registro con ${loan.counterpartyName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await LoanNotificationService.instance.cancel(loan.id);
    await ref.read(financeRepositoryProvider).deleteLoan(loan.id);
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _LoanTile extends StatelessWidget {
  const _LoanTile({
    required this.loan,
    required this.currency,
    required this.onTap,
    required this.onToggleSettled,
    required this.onDelete,
  });

  final LoanModel loan;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback onToggleSettled;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = loan.direction == LoanDirection.borrowed
        ? AppColors.expense
        : AppColors.income;
    final dueLabel = DateFormat.yMMMd('es').format(loan.dueDate);
    final status = loan.isSettled
        ? 'Saldado'
        : loan.isOverdue
            ? 'Vencido'
            : loan.daysUntilDue == 0
                ? 'Vence hoy'
                : 'Vence en ${loan.daysUntilDue} días';

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(loan.direction.icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.counterpartyName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration:
                            loan.isSettled ? TextDecoration.lineThrough : null,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${loan.direction.shortLabel} · ${loan.counterpartyType.label} · $dueLabel',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.financeMuted,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: loan.isSettled
                            ? context.financeMuted
                            : loan.isOverdue
                                ? AppColors.expense
                                : AppColors.teal,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MoneyFormat.format(loan.amountCents, currencyCode: currency),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (loan.notifyEnabled && !loan.isSettled)
                    Icon(
                      Icons.notifications_active_outlined,
                      size: 16,
                      color: context.financeMuted,
                    ),
                  IconButton(
                    tooltip: loan.isSettled ? 'Reabrir' : 'Marcar saldado',
                    onPressed: onToggleSettled,
                    icon: Icon(
                      loan.isSettled
                          ? Icons.undo_rounded
                          : Icons.check_circle_outline_rounded,
                      color: AppColors.teal,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
