import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/domain/models/transaction.dart';
import 'package:my_personal_finance_app/features/transactions/presentation/add_transaction_screen.dart';

Future<void> openTransactionEditor(
  BuildContext context, {
  TransactionModel? transaction,
}) {
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: AddTransactionScreen(transaction: transaction),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    ),
  );
}
