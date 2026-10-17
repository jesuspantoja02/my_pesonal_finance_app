import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/constants/peruvian_banks.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/services/loan_notification_service.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/utils/money_format.dart';
import 'package:my_personal_finance_app/core/widgets/wallet_brand_badge.dart';
import 'package:my_personal_finance_app/domain/models/loan.dart';

Future<void> showAddLoanSheet(
  BuildContext context,
  WidgetRef ref, {
  LoanModel? loan,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => AddLoanSheet(loan: loan),
  );
}

class AddLoanSheet extends ConsumerStatefulWidget {
  const AddLoanSheet({super.key, this.loan});

  final LoanModel? loan;

  bool get isEditing => loan != null;

  @override
  ConsumerState<AddLoanSheet> createState() => _AddLoanSheetState();
}

class _AddLoanSheetState extends ConsumerState<AddLoanSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late LoanDirection _direction;
  late LoanCounterpartyType _counterpartyType;
  late DateTime _dueDate;
  late bool _notifyEnabled;
  late TimeOfDay _notifyTime;
  late bool _notifyRepeatHourly;
  String? _bankId;

  @override
  void initState() {
    super.initState();
    final loan = widget.loan;
    _direction = loan?.direction ?? LoanDirection.borrowed;
    _counterpartyType = loan?.counterpartyType ?? LoanCounterpartyType.person;
    _dueDate = loan?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _notifyEnabled = loan?.notifyEnabled ?? true;
    _notifyTime = loan?.notifyTimeOfDay ?? const TimeOfDay(hour: 9, minute: 0);
    _notifyRepeatHourly = loan?.notifyRepeatHourly ?? false;
    _bankId = loan?.bankId ?? PeruvianBanks.all.first.id;
    _nameController = TextEditingController(
      text: loan?.counterpartyName ?? '',
    );
    _amountController = TextEditingController(
      text: loan == null ? '' : (loan.amountCents / 100).toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: loan?.note ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final firstDate = DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 365 * 5));
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Día de pago',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                CalendarDatePicker(
                  initialDate: _dueDate.isBefore(firstDate)
                      ? firstDate
                      : (_dueDate.isAfter(lastDate) ? lastDate : _dueDate),
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
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickNotifyTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notifyTime,
      helpText: 'Hora del recordatorio',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _notifyTime = picked);
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _save() async {
    final cents = MoneyFormat.parseToCents(_amountController.text);
    final name = _counterpartyType == LoanCounterpartyType.bank
        ? (PeruvianBanks.nameForId(_bankId) ?? _nameController.text.trim())
        : _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage(
        _counterpartyType == LoanCounterpartyType.bank
            ? 'Selecciona el banco'
            : 'Escribe el nombre de la persona',
      );
      return;
    }
    if (cents <= 0) {
      _showMessage('Ingresa un monto válido');
      return;
    }

    if (_notifyEnabled) {
      await LoanNotificationService.instance.requestPermissionIfNeeded();
    }

    final saved = await ref.read(financeRepositoryProvider).upsertLoan(
          id: widget.loan?.id,
          direction: _direction,
          counterpartyType: _counterpartyType,
          counterpartyName: name,
          amountCents: cents,
          dueDate: _dueDate,
          note: _noteController.text.trim(),
          notifyEnabled: _notifyEnabled,
          notifyHour: _notifyTime.hour,
          notifyMinute: _notifyTime.minute,
          notifyRepeatHourly: _notifyRepeatHourly,
          isSettled: widget.loan?.isSettled ?? false,
          bankId: _bankId,
          createdAt: widget.loan?.createdAt,
        );

    final notifications = LoanNotificationService.instance;
    if (saved.notifyEnabled && !saved.isSettled) {
      final currency =
          ref.read(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
      final amount = MoneyFormat.format(saved.amountCents, currencyCode: currency);
      final title = saved.direction == LoanDirection.borrowed
          ? 'Hoy debes pagar un préstamo'
          : 'Hoy te deben pagar';
      final body = saved.direction == LoanDirection.borrowed
          ? 'Paga $amount a ${saved.counterpartyName}'
          : '${saved.counterpartyName} te debe $amount';
      await notifications.scheduleDueReminder(
        loanId: saved.id,
        title: title,
        body: body,
        dueDate: saved.dueDate,
        hour: saved.notifyHour,
        minute: saved.notifyMinute,
        repeatHourly: saved.notifyRepeatHourly,
      );
    } else {
      await notifications.cancel(saved.id);
    }

    if (mounted) Navigator.pop(context);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final currency =
        ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.financeSubtleBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isEditing ? 'Editar préstamo' : 'Nuevo préstamo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Text(
            'Tipo',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ChoiceCard(
                  selected: _direction == LoanDirection.borrowed,
                  color: AppColors.expense,
                  icon: LoanDirection.borrowed.icon,
                  label: 'Me prestaron',
                  subtitle: 'Yo debo pagar',
                  onTap: () =>
                      setState(() => _direction = LoanDirection.borrowed),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChoiceCard(
                  selected: _direction == LoanDirection.lent,
                  color: AppColors.income,
                  icon: LoanDirection.lent.icon,
                  label: 'Yo presté',
                  subtitle: 'Me deben pagar',
                  onTap: () => setState(() => _direction = LoanDirection.lent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '¿De quién / a quién?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: LoanCounterpartyType.values.map((type) {
              final selected = _counterpartyType == type;
              return ChoiceChip(
                label: Text(type.label),
                selected: selected,
                onSelected: (_) => setState(() => _counterpartyType = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          if (_counterpartyType == LoanCounterpartyType.person)
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: _direction == LoanDirection.borrowed
                    ? 'Nombre de quien te prestó'
                    : 'Nombre de a quien le prestaste',
                hintText: 'Ej. Carlos',
              ),
            )
          else ...[
            Center(child: BankBrandBadge(bankId: _bankId ?? 'otro', size: 64)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('loan-bank-$_bankId'),
              initialValue: _bankId ?? PeruvianBanks.all.first.id,
              decoration: const InputDecoration(labelText: 'Banco'),
              isExpanded: true,
              items: PeruvianBanks.all
                  .map(
                    (bank) => DropdownMenuItem(
                      value: bank.id,
                      child: Row(
                        children: [
                          BankBrandBadge(bankId: bank.id, size: 28),
                          const SizedBox(width: 10),
                          Expanded(child: Text(bank.name)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _bankId = value;
                  _nameController.text = PeruvianBanks.nameForId(value) ?? '';
                });
              },
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: 'Monto',
              prefixText: '${MoneyFormat.currencySymbol(currency)} ',
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.event_rounded, color: AppColors.teal),
            title: const Text('Día de pago'),
            subtitle: Text(
              '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDueDate,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _notifyEnabled,
            onChanged: (value) => setState(() => _notifyEnabled = value),
            title: const Text('Notificarme el día de pago'),
            subtitle: Text(
              _direction == LoanDirection.borrowed
                  ? 'Recibe un aviso el día en que debes pagar'
                  : 'Recibe un aviso el día en que te deben pagar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.financeMuted,
                  ),
            ),
            secondary: Icon(
              _notifyEnabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: AppColors.teal,
            ),
          ),
          if (_notifyEnabled) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.schedule_rounded, color: AppColors.teal),
              title: const Text('Hora del recordatorio'),
              subtitle: Text(
                _formatTime(_notifyTime),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickNotifyTime,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _notifyRepeatHourly,
              onChanged: (value) =>
                  setState(() => _notifyRepeatHourly = value),
              title: const Text('Repetir cada hora'),
              subtitle: Text(
                'Desde la hora elegida, te avisará cada hora hasta que marques el préstamo como saldado',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.financeMuted,
                    ),
              ),
              secondary: Icon(
                Icons.loop_rounded,
                color: AppColors.teal,
              ),
            ),
          ],
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Nota (opcional)',
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(widget.isEditing ? 'Guardar cambios' : 'Registrar préstamo'),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.color,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final Color color;
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.16) : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : context.financeSubtleBorder,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : context.financeMuted),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? color : null,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.financeMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
