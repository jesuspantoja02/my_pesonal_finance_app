import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/utils/icon_from_codepoint.dart';
import 'package:my_personal_finance_app/core/utils/money_format.dart';
import 'package:my_personal_finance_app/core/widgets/glass_card.dart';
import 'package:my_personal_finance_app/domain/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currencyCode,
    this.onTap,
  });

  final TransactionModel transaction;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = transaction.categoryIconCodePoint != null
        ? iconFromCodePoint(transaction.categoryIconCodePoint!)
        : Icons.swap_horiz;
    final amountPrefix = transaction.isIncome ? '+' : '-';
    final amountColor =
        transaction.isIncome ? AppColors.income : AppColors.expense;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: amountColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.categoryName ?? 'Categoría',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.accountName ?? 'Cuenta'} · ${DateFormat.MMMd('es').format(transaction.date)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.financeMuted,
                      ),
                ),
                if (transaction.note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.financeMuted,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix${MoneyFormat.format(transaction.amountCents, currencyCode: currencyCode)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                    ),
              ),
              if (onTap != null) ...[
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: context.financeChevron,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
