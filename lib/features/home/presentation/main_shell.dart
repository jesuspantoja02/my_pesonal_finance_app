import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_personal_finance_app/core/motion/app_motion.dart';
import 'package:my_personal_finance_app/core/motion/app_page_transition.dart';
import 'package:my_personal_finance_app/core/widgets/gradient_scaffold.dart';
import 'package:my_personal_finance_app/features/accounts/presentation/accounts_screen.dart';
import 'package:my_personal_finance_app/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:my_personal_finance_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:my_personal_finance_app/features/home/presentation/widgets/main_shell_bottom_bar.dart';
import 'package:my_personal_finance_app/features/loans/presentation/loans_screen.dart';
import 'package:my_personal_finance_app/features/loans/presentation/widgets/add_loan_sheet.dart';
import 'package:my_personal_finance_app/features/settings/presentation/settings_screen.dart';
import 'package:my_personal_finance_app/features/transactions/presentation/transaction_editor.dart';
import 'package:my_personal_finance_app/features/transactions/presentation/transactions_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;
  int _previousIndex = 0;

  static const _pages = [
    DashboardScreen(),
    TransactionsScreen(),
    AccountsScreen(),
    LoansScreen(),
    SettingsScreen(),
  ];

  Future<void> _onPrimaryAction() async {
    if (_index == 0 || _index == 1) {
      await openTransactionEditor(context);
      return;
    }
    if (_index == 2) {
      await showAddAccountSheet(context, ref);
      return;
    }
    if (_index == 3) {
      await showAddLoanSheet(context, ref);
    }
  }

  void _onTab(int value) {
    if (value == _index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _previousIndex = _index;
      _index = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showPrimary = MainShellBottomBar.labelForIndex(_index) != null;

    return GradientScaffold(
      body: AnimatedSwitcher(
        duration: AppMotion.standard,
        switchInCurve: AppMotion.easeOut,
        switchOutCurve: AppMotion.easeIn,
        transitionBuilder: (child, animation) {
          return tabSwitchTransition(child, animation, _previousIndex, _index);
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_index),
          child: _pages[_index],
        ),
      ),
      bottomNavigationBar: MainShellBottomBar(
        selectedIndex: _index,
        onDestinationSelected: _onTab,
        onPrimaryAction: showPrimary ? _onPrimaryAction : null,
      ),
    );
  }
}
