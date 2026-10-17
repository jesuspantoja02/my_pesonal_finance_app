import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/widgets/glass_card.dart';
import 'package:my_personal_finance_app/core/widgets/gradient_scaffold.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _pinFieldsVisible = false;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();
    if (pin.length != 4 || confirm.length != 4) {
      _snack('El PIN debe tener 4 dígitos');
      return;
    }
    if (pin != confirm) {
      _snack('Los PIN no coinciden');
      return;
    }
    await ref.read(appLockServiceProvider).setPin(pin);
    await ref.read(financeRepositoryProvider).updateAppPreferences(
          appLockEnabled: true,
        );
    _pinController.clear();
    _confirmController.clear();
    setState(() => _pinFieldsVisible = false);
    _snack('Bloqueo guardado');
  }

  Future<void> _disableLock() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar bloqueo'),
        content: const Text(
          'Se eliminará el PIN guardado en este dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(appLockServiceProvider).clearPin();
    await ref.read(financeRepositoryProvider).updateAppPreferences(
          appLockEnabled: false,
        );
    setState(() => _pinFieldsVisible = false);
    _snack('Bloqueo desactivado');
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPreferencesProvider).valueOrNull;
    final lockEnabled = prefs?.appLockEnabled ?? false;

    return GradientScaffold(
      appBar: AppBar(title: const Text('Seguridad')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bloqueo con PIN',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Protege la app al abrirla. Opcionalmente usa huella o Face ID en la pantalla de bloqueo.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.financeMuted,
                      ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activar bloqueo'),
                  value: lockEnabled,
                  onChanged: (value) async {
                    if (value) {
                      setState(() => _pinFieldsVisible = true);
                    } else {
                      await _disableLock();
                    }
                  },
                ),
                if (lockEnabled || _pinFieldsVisible) ...[
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: lockEnabled ? 'Nuevo PIN' : 'PIN',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Confirmar PIN',
                      counterText: '',
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _savePin,
                  child: Text(lockEnabled ? 'Actualizar PIN' : 'Guardar y activar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
