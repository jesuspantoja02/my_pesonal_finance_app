import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/layout/main_shell_metrics.dart';
import 'package:my_personal_finance_app/core/motion/fade_slide_in.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/ui/app_empty_state.dart';
import 'package:my_personal_finance_app/core/ui/app_screen_header.dart';
import 'package:my_personal_finance_app/core/utils/money_format.dart';
import 'package:my_personal_finance_app/core/widgets/glass_card.dart';
import 'package:my_personal_finance_app/core/widgets/payment_card_badge.dart';
import 'package:my_personal_finance_app/domain/models/account.dart';
import 'package:my_personal_finance_app/features/accounts/presentation/widgets/add_account_sheet.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _selecting = false;
  final Set<String> _selectedIds = {};

  void _exitSelection() {
    setState(() {
      _selecting = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(AccountModel account) {
    if (account.type == AccountType.cash) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('La cuenta de efectivo no se puede eliminar'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() {
      if (_selectedIds.contains(account.id)) {
        _selectedIds.remove(account.id);
        if (_selectedIds.isEmpty) _selecting = false;
      } else {
        _selectedIds.add(account.id);
      }
    });
  }

  Future<void> _confirmDeleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(count == 1 ? '¿Eliminar cuenta?' : '¿Eliminar $count cuentas?'),
        content: Text(
          count == 1
              ? 'Se borrarán también sus movimientos. Esta acción no se puede deshacer.'
              : 'Se borrarán también los movimientos de esas cuentas. Esta acción no se puede deshacer.',
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
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(financeRepositoryProvider).deleteAccounts(_selectedIds);
      if (!mounted) return;
      _exitSelection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(count == 1 ? 'Cuenta eliminada' : '$count cuentas eliminadas'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Bad state: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
    final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
    final bottomPadding = MainShellMetrics.contentBottomPadding(context);
    final deletableCount =
        accounts.where((a) => a.type != AccountType.cash).length;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppScreenHeader(
            title: _selecting
                ? '${_selectedIds.length} seleccionada${_selectedIds.length == 1 ? '' : 's'}'
                : 'Cuentas',
            subtitle: _selecting
                ? 'Elige cuentas para eliminar (efectivo no se puede)'
                : 'Efectivo, bancos y billeteras',
            trailing: _selecting
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Cancelar',
                        onPressed: _exitSelection,
                        icon: const Icon(Icons.close_rounded),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        onPressed: _selectedIds.isEmpty
                            ? null
                            : _confirmDeleteSelected,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: _selectedIds.isEmpty
                              ? null
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  )
                : deletableCount > 0
                    ? IconButton(
                        tooltip: 'Seleccionar',
                        onPressed: () => setState(() => _selecting = true),
                        icon: const Icon(Icons.checklist_rounded),
                      )
                    : null,
          ),
          Expanded(
            child: accounts.isEmpty
                ? const AppEmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Sin cuentas',
                    message:
                        'Agrega efectivo, Yape, Plin o un banco para empezar.',
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPadding),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final isCash = account.type == AccountType.cash;
                      final selected = _selectedIds.contains(account.id);

                      return FadeSlideIn(
                        delay: Duration(milliseconds: 40 * (index.clamp(0, 8))),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            onTap: () {
                              if (_selecting) {
                                _toggleSelect(account);
                                return;
                              }
                              showAddAccountSheet(
                                context,
                                ref,
                                account: account,
                              );
                            },
                            onLongPress: isCash
                                ? null
                                : () {
                                    setState(() {
                                      _selecting = true;
                                      _selectedIds.add(account.id);
                                    });
                                  },
                            child: Row(
                              children: [
                                if (_selecting) ...[
                                  Icon(
                                    isCash
                                        ? Icons.lock_outline_rounded
                                        : selected
                                            ? Icons.check_circle_rounded
                                            : Icons.circle_outlined,
                                    color: isCash
                                        ? context.financeMuted
                                        : selected
                                            ? Theme.of(context).colorScheme.primary
                                            : context.financeMuted,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                AccountLeadingVisual(account: account),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      Text(
                                        isCash && _selecting
                                            ? '${account.typeSubtitle} · no se puede eliminar'
                                            : account.typeSubtitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: context.financeMuted,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  MoneyFormat.format(
                                    account.balanceCents,
                                    currencyCode: currency,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                if (!_selecting) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: context.financeChevron,
                                  ),
                                ],
                              ],
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
