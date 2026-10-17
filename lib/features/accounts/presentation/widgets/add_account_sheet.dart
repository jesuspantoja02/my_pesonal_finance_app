import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/constants/peruvian_banks.dart';
import 'package:my_personal_finance_app/core/constants/peruvian_digital_wallets.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/widgets/payment_card_badge.dart';
import 'package:my_personal_finance_app/core/widgets/wallet_brand_badge.dart';
import 'package:my_personal_finance_app/domain/models/account.dart';
import 'package:my_personal_finance_app/domain/models/card_kind.dart';
import 'package:my_personal_finance_app/domain/models/card_network.dart';

Future<void> showAddAccountSheet(
  BuildContext context,
  WidgetRef ref, {
  AccountModel? account,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => AddAccountSheet(account: account),
  );
}

class AddAccountSheet extends ConsumerStatefulWidget {
  const AddAccountSheet({super.key, this.account});

  final AccountModel? account;

  bool get isEditing => account != null;

  @override
  ConsumerState<AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends ConsumerState<AddAccountSheet> {
  late final TextEditingController _nameController;
  late AccountType _type;
  String? _providerId;
  late CardKind _cardKind;
  late CardNetwork _cardNetwork;

  List<AccountType> _typeOptions(List<AccountModel> accounts) {
    final options = List<AccountType>.from(AccountTypeDisplay.selectable);
    final editingId = widget.account?.id;
    final hasOtherCash = accounts.any(
      (a) => a.type == AccountType.cash && a.id != editingId,
    );
    if (hasOtherCash) {
      options.remove(AccountType.cash);
    }
    if (widget.account?.type == AccountType.bank &&
        !options.contains(AccountType.bank)) {
      options.add(AccountType.bank);
    }
    return options;
  }

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _nameController = TextEditingController(text: account?.name ?? '');
    _type = account?.type ?? AccountType.cash;
    _providerId = account?.bankId;
    _cardKind = account?.cardKind ?? CardKind.debit;
    _cardNetwork = account?.cardNetwork ?? CardNetwork.visa;
    _syncProviderForType(_type);
    if (_type == AccountType.cash) {
      _nameController.text = kDefaultCashAccountName;
    }
  }

  void _syncProviderForType(AccountType type) {
    if (type == AccountType.cash) {
      _providerId = null;
      _nameController.text = kDefaultCashAccountName;
      return;
    }
    if (type == AccountType.digitalWallet) {
      if (_providerId == null ||
          !PeruvianDigitalWallets.all.any((w) => w.id == _providerId)) {
        _providerId = PeruvianDigitalWallets.all.first.id;
      }
      _nameController.text =
          PeruvianDigitalWallets.nameForId(_providerId) ?? 'Billetera digital';
      return;
    }
    if (_providerId == null ||
        !PeruvianBanks.all.any((b) => b.id == _providerId)) {
      _providerId = PeruvianBanks.all.first.id;
    }
  }

  void _onWalletChanged(String walletId) {
    setState(() {
      _providerId = walletId;
      _nameController.text =
          PeruvianDigitalWallets.nameForId(walletId) ?? 'Billetera digital';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = ref.read(financeRepositoryProvider);
    final resolvedName = switch (_type) {
      AccountType.cash => kDefaultCashAccountName,
      AccountType.digitalWallet =>
        PeruvianDigitalWallets.nameForId(_providerId) ?? 'Billetera digital',
      _ => _nameController.text.trim(),
    };

    if (resolvedName.isEmpty) {
      _showMessage('Escribe un nombre para la cuenta');
      return;
    }

    if (_type == AccountType.cash) {
      final duplicateCash = await repo.hasCashAccount(
        exceptAccountId: widget.account?.id,
      );
      if (duplicateCash) {
        _showMessage('Ya tienes la cuenta de $kDefaultCashAccountName');
        return;
      }
    }

    if (_type.needsProvider &&
        (_providerId == null || _providerId!.isEmpty)) {
      _showMessage(
        _type == AccountType.digitalWallet
            ? 'Selecciona la billetera'
            : 'Selecciona el banco de tu tarjeta',
      );
      return;
    }

    if (_type == AccountType.bank &&
        (_providerId == null || _providerId!.isEmpty)) {
      _showMessage('Selecciona el banco');
      return;
    }

    await repo.upsertAccount(
      id: widget.account?.id,
      name: resolvedName,
      type: _type,
      initialBalanceCents: widget.account?.initialBalanceCents ?? 0,
      colorValue: _type == AccountType.card
          ? _cardNetwork.brandColor.toARGB32()
          : (widget.account?.colorValue ?? 0xFF14B8A6),
      bankId: _providerId,
      cardKind: _type == AccountType.card ? _cardKind : null,
      cardNetwork: _type == AccountType.card ? _cardNetwork : null,
    );

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

  void _onTypeChanged(AccountType type) {
    setState(() {
      _type = type;
      _syncProviderForType(type);
    });
  }

  String _bankDropdownValue() {
    final id = _providerId;
    if (id != null && PeruvianBanks.all.any((b) => b.id == id)) {
      return id;
    }
    return PeruvianBanks.all.first.id;
  }

  String _walletDropdownValue() {
    final id = _providerId;
    final resolved = PeruvianDigitalWallets.byId(id)?.id;
    if (resolved != null) return resolved;
    return PeruvianDigitalWallets.all.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
    final typeOptions = _typeOptions(accounts);
    final isCash = _type == AccountType.cash;

    if (!typeOptions.contains(_type) && typeOptions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onTypeChanged(typeOptions.first);
      });
    }

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
            widget.isEditing ? 'Editar cuenta' : 'Nueva cuenta',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Text(
            'Categoría',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: typeOptions.map((type) {
              final selected = _type == type;
              return ChoiceChip(
                label: Text(
                  type.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : null,
                  ),
                ),
                selected: selected,
                onSelected: (_) => _onTypeChanged(type),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (_type != AccountType.digitalWallet)
            TextField(
              controller: _nameController,
              readOnly: isCash,
              enableInteractiveSelection: !isCash,
              decoration: InputDecoration(
                labelText: 'Nombre de la cuenta',
                hintText: isCash ? null : 'Ej. Tarjeta principal',
                helperText: isCash
                    ? 'La cuenta de efectivo siempre se llama $kDefaultCashAccountName'
                    : null,
              ),
            ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildProviderFields(),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(widget.isEditing ? 'Guardar cambios' : 'Crear cuenta'),
          ),
          if (widget.isEditing &&
              widget.account!.type != AccountType.cash) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _confirmDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Eliminar cuenta'),
            ),
          ],
          if (widget.isEditing && widget.account!.type == AccountType.cash) ...[
            const SizedBox(height: 12),
            Text(
              'La cuenta de efectivo no se puede eliminar.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.financeMuted,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final account = widget.account;
    if (account == null || account.type == AccountType.cash) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: Text(
          'Se eliminará “${account.name}” y todos sus movimientos. '
          'Esta acción no se puede deshacer.',
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
      await ref.read(financeRepositoryProvider).deleteAccount(account.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  Widget _buildProviderFields() {
    if (_type == AccountType.digitalWallet) {
      return Column(
        key: const ValueKey('wallet-fields'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            '¿Qué billetera usas?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Center(
            child: WalletBrandBadge(walletId: _walletDropdownValue(), size: 72),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            key: ValueKey('wallet-${_walletDropdownValue()}'),
            initialValue: _walletDropdownValue(),
            decoration: const InputDecoration(
              labelText: 'Billetera digital',
              helperText: 'Yape, Plin, Tunki, Agora, SIP u otra',
            ),
            isExpanded: true,
            items: PeruvianDigitalWallets.all
                .map(
                  (wallet) => DropdownMenuItem(
                    value: wallet.id,
                    child: Row(
                      children: [
                        WalletBrandBadge(walletId: wallet.id, size: 32),
                        const SizedBox(width: 10),
                        Expanded(child: Text(wallet.name)),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) _onWalletChanged(value);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'La cuenta se llamará como la billetera que elijas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.financeMuted,
                ),
          ),
        ],
      );
    }

    if (_type == AccountType.card || _type == AccountType.bank) {
      final isLegacyBank = _type == AccountType.bank;
      return Column(
        key: ValueKey(isLegacyBank ? 'legacy-bank' : 'card-fields'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isLegacyBank) ...[
            const SizedBox(height: 20),
            Text(
              'Marca de la tarjeta',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Elige el icono como en una tarjeta real',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.financeMuted,
                  ),
            ),
            const SizedBox(height: 12),
            Center(
              child: PaymentCardBadge(
                network: _cardNetwork,
                width: 168,
                height: 104,
              ),
            ),
            const SizedBox(height: 14),
            CardNetworkPicker(
              value: _cardNetwork,
              onChanged: (network) => setState(() => _cardNetwork = network),
            ),
            const SizedBox(height: 20),
            Text(
              'Tipo de tarjeta',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CardKind.values.map((kind) {
                final selected = _cardKind == kind;
                return ChoiceChip(
                  label: Text(
                    kind.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : null,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) => setState(() => _cardKind = kind),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            isLegacyBank ? '¿En qué banco?' : '¿De qué banco es tu tarjeta?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Center(
            child: BankBrandBadge(bankId: _bankDropdownValue(), size: 72),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            key: ValueKey('bank-${_bankDropdownValue()}'),
            initialValue: _bankDropdownValue(),
            decoration: InputDecoration(
              labelText: isLegacyBank ? 'Banco' : 'Banco emisor',
              helperText: isLegacyBank
                  ? null
                  : 'Bancos que emiten tarjetas en Perú',
            ),
            isExpanded: true,
            items: PeruvianBanks.all
                .map(
                  (bank) => DropdownMenuItem(
                    value: bank.id,
                    child: Row(
                      children: [
                        BankBrandBadge(bankId: bank.id, size: 32),
                        const SizedBox(width: 10),
                        Expanded(child: Text(bank.name)),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _providerId = value);
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink(key: ValueKey('no-provider'));
  }
}
