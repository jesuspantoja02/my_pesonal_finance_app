import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/utils/money_format.dart';
import 'package:my_personal_finance_app/core/widgets/finance_bottom_sheet.dart';
import 'package:my_personal_finance_app/core/widgets/glass_card.dart';
import 'package:my_personal_finance_app/core/widgets/gradient_scaffold.dart';
import 'package:my_personal_finance_app/core/widgets/payment_card_badge.dart';
import 'package:my_personal_finance_app/domain/models/account.dart';
import 'package:my_personal_finance_app/domain/models/category.dart';
import 'package:my_personal_finance_app/domain/models/transaction.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.transaction});

  final TransactionModel? transaction;

  bool get isEditing => transaction != null;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isIncome = false;
  DateTime _date = DateTime.now();
  String? _accountId;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx == null) return;

    _isIncome = tx.isIncome;
    _date = tx.date;
    _accountId = tx.accountId;
    _categoryId = tx.categoryId;
    _amountController.text = (tx.amountCents / 100).toStringAsFixed(2);
    _noteController.text = tx.note;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final accounts = ref.read(accountsProvider).valueOrNull ?? [];
    final categories = ref.read(categoriesProvider).valueOrNull ?? [];
    final filteredCategories =
        categories.where((c) => c.isExpense != _isIncome).toList();

    final accountId = _accountId ?? accounts.firstOrNull?.id;
    final categoryId = _categoryId ?? filteredCategories.firstOrNull?.id;
    final cents = MoneyFormat.parseToCents(_amountController.text);

    if (accountId == null || categoryId == null || cents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Completa monto, cuenta y categoría'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final repo = ref.read(financeRepositoryProvider);
    final note = _noteController.text.trim();
    if (widget.isEditing) {
      await repo.updateTransaction(
        id: widget.transaction!.id,
        accountId: accountId,
        categoryId: categoryId,
        amountCents: cents,
        isIncome: _isIncome,
        date: _date,
        note: note,
      );
    } else {
      await repo.addTransaction(
        accountId: accountId,
        categoryId: categoryId,
        amountCents: cents,
        isIncome: _isIncome,
        date: _date,
        note: note,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref
        .read(financeRepositoryProvider)
        .deleteTransaction(widget.transaction!.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now().add(const Duration(days: 365));
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Selecciona una fecha',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                CalendarDatePicker(
                  initialDate: _date.isBefore(firstDate)
                      ? firstDate
                      : (_date.isAfter(lastDate) ? lastDate : _date),
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onDateChanged: (date) => Navigator.of(ctx).pop(date),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
    final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final filtered =
        categories.where((c) => c.isExpense != _isIncome).toList();

    if (!widget.isEditing) {
      _accountId ??= accounts.firstOrNull?.id;
      _categoryId ??= filtered.firstOrNull?.id;
    }

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.isEditing ? 'Detalle del movimiento' : 'Nuevo movimiento'),
        actions: [
          if (widget.isEditing)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            FadeInDown(
              child: Column(
                children: [
                  _ContextMotionIcon(isIncome: _isIncome),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: _TypeToggle(
                            label: 'Gasto',
                            selected: !_isIncome,
                            color: AppColors.expense,
                            onTap: () => setState(() {
                              _isIncome = false;
                              _categoryId = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TypeToggle(
                            label: 'Ingreso',
                            selected: _isIncome,
                            color: AppColors.income,
                            onTap: () => setState(() {
                              _isIncome = true;
                              _categoryId = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 80),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                decoration: InputDecoration(
                  prefixText: '${MoneyFormat.currencySymbol(currency)} ',
                  hintText: '0.00',
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 120),
              child: Builder(
                builder: (context) {
                  final account = accounts
                      .where((a) => a.id == _accountId)
                      .firstOrNull;
                  final value = () {
                    if (account == null) return 'Seleccionar';
                    if (account.type == AccountType.card) {
                      return '${account.name} · ${account.typeSubtitle}';
                    }
                    if (account.type == AccountType.digitalWallet &&
                        account.bankId != null) {
                      final suffix = account.typeSubtitle.split(' · ').last;
                      return '${account.name} · $suffix';
                    }
                    if (account.type.isBank && account.bankId != null) {
                      return '${account.name} · ${account.typeSubtitle.split(' · ').last}';
                    }
                    return account.name;
                  }();
                  return _PickerTile(
                    label: 'Cuenta',
                    value: value,
                    leading: account == null
                        ? null
                        : AccountLeadingVisual(account: account, size: 40),
                    onTap: () => _showAccountPicker(accounts),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              delay: const Duration(milliseconds: 160),
              child: _PickerTile(
                label: 'Categoría',
                value: filtered
                        .where((c) => c.id == _categoryId)
                        .map((c) => c.name)
                        .firstOrNull ??
                    'Seleccionar',
                onTap: () => _showCategoryPicker(filtered),
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _PickerTile(
                label: 'Fecha',
                value:
                    '${_date.day}/${_date.month}/${_date.year}',
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              delay: const Duration(milliseconds: 240),
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(widget.isEditing ? 'Guardar cambios' : 'Guardar movimiento'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAccountPicker(List<AccountModel> accounts) async {
    await showFinanceBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final onSurface = theme.colorScheme.onSurface;
        final muted = theme.colorScheme.onSurfaceVariant;

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  'Elige una cuenta',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...accounts.map(
                (a) => ListTile(
                  leading: AccountLeadingVisual(account: a, size: 44),
                  title: Text(
                    a.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    a.typeSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                  onTap: () {
                    setState(() => _accountId = a.id);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCategoryPicker(List<CategoryModel> categories) async {
    await showFinanceBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final onSurface = theme.colorScheme.onSurface;
        final primary = theme.colorScheme.primary;

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  'Elige una categoría',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...categories.map(
                (c) => ListTile(
                  leading: Icon(c.icon, color: primary),
                  title: Text(
                    c.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    setState(() => _categoryId = c.id);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContextMotionIcon extends StatelessWidget {
  const _ContextMotionIcon({required this.isIncome});

  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? AppColors.income : AppColors.expense;
    final icon = isIncome
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final caption = isIncome ? 'Registrando un ingreso' : 'Registrando un gasto';

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Pulse(
            key: ValueKey<bool>(isIncome),
            infinite: true,
            duration: const Duration(milliseconds: 1400),
            from: 1,
            to: 1.08,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.28),
                    color.withValues(alpha: 0.12),
                  ],
                ),
                border: Border.all(color: color.withValues(alpha: 0.45)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, size: 36, color: color),
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            caption,
            key: ValueKey<String>(caption),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? color : context.financeSubtleBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? color : context.financeMuted,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.leading,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: context.financeMuted,
                ),
          ),
          const SizedBox(width: 12),
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.financeOnSurface,
                  ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: context.financeChevron),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
