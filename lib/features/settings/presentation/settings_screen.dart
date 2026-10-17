import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/layout/main_shell_metrics.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/ui/app_screen_header.dart';
import 'package:my_personal_finance_app/core/widgets/app_credit_footer.dart';
import 'package:my_personal_finance_app/core/widgets/glass_card.dart';
import 'package:my_personal_finance_app/domain/models/app_preferences.dart';
import 'package:my_personal_finance_app/features/budgets/presentation/budgets_screen.dart';
import 'package:my_personal_finance_app/features/insights/presentation/insights_screen.dart';
import 'package:my_personal_finance_app/features/security/presentation/security_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _currencies = ['PEN', 'USD', 'EUR', 'MXN', 'COP', 'ARS'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider).valueOrNull ?? kDefaultCurrencyCode;
    final prefs = ref.watch(appPreferencesProvider).valueOrNull;
    final themePreference =
        prefs?.themePreference ?? AppThemePreference.dark;
    final versionLabel = ref.watch(appVersionLabelProvider);
    final bottomPadding = MainShellMetrics.contentBottomPadding(context);
    final muted = context.financeMuted;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPadding),
        children: [
          const AppScreenHeader(
            title: 'Ajustes',
            subtitle: 'Preferencias, seguridad y datos',
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
          FadeInUp(
            child: GlassCard(
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) => const BudgetsScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.pie_chart_outline, color: AppColors.teal),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Presupuestos mensuales',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'Define límites por categoría de gasto',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 50),
            child: GlassCard(
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) => const InsightsScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.insights, color: AppColors.emerald.withValues(alpha: 0.9)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Análisis y gráficos',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'Gastos por categoría y tendencia mensual',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 70),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apariencia',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<AppThemePreference>(
                    segments: const [
                      ButtonSegment(
                        value: AppThemePreference.dark,
                        label: Text('Oscuro'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                      ButtonSegment(
                        value: AppThemePreference.light,
                        label: Text('Claro'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: AppThemePreference.system,
                        label: Text('Sistema'),
                        icon: Icon(Icons.settings_brightness_outlined),
                      ),
                    ],
                    selected: {themePreference},
                    onSelectionChanged: (selection) {
                      ref.read(financeRepositoryProvider).updateAppPreferences(
                            themePreference: selection.first,
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 75),
            child: GlassCard(
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) => const SecuritySettingsScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.teal),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seguridad',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          prefs?.appLockEnabled == true
                              ? 'Bloqueo con PIN activo'
                              : 'PIN y biometría opcionales',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 78),
            child: GlassCard(
              onTap: () async {
                await ref.read(authServiceProvider).signOut();
                ref.invalidate(currentAuthUserProvider);
                if (context.mounted) context.go('/onboarding');
              },
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.teal),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cerrar sesión',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'Volver a la pantalla de acceso',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 80),
            child: GlassCard(
              onTap: () async {
                try {
                  await ref.read(exportServiceProvider).shareTransactionsCsv(
                        currencyCode: currency,
                      );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No se pudo exportar: $e')),
                    );
                  }
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.ios_share, color: AppColors.teal),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exportar movimientos',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'CSV para Excel o Google Sheets',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 85),
            child: GlassCard(
              onTap: () async {
                try {
                  await ref
                      .read(exportServiceProvider)
                      .shareTransactionsForGoogleSheets(currencyCode: currency);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No se pudo exportar: $e')),
                    );
                  }
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.table_chart_outlined, color: AppColors.teal),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Abrir en Google Sheets',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'CSV listo para importar en Sheets (desde tu dispositivo)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 90),
            child: GlassCard(
              onTap: () async {
                try {
                  await ref.read(backupServiceProvider).shareBackup();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No se pudo exportar respaldo: $e')),
                    );
                  }
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.backup_outlined, color: AppColors.teal),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Respaldo JSON',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'Cuentas, categorías, movimientos y ajustes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 95),
            child: GlassCard(
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Importar respaldo'),
                    content: const Text(
                      'Se reemplazarán todos los datos locales con el archivo JSON. '
                      'Esta acción no se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Importar'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;

                try {
                  final imported =
                      await ref.read(backupServiceProvider).importBackupFromPicker();
                  if (!context.mounted) return;
                  if (imported) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Respaldo importado correctamente')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Importación fallida: $e')),
                    );
                  }
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.file_upload_outlined, color: AppColors.emerald),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restaurar respaldo',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'Selecciona un archivo .json exportado antes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 110),
            child: GlassCard(
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Borrar todos los datos'),
                    content: const Text(
                      'Se eliminarán cuentas, movimientos, presupuestos y categorías. '
                      'Quedarán solo las categorías por defecto y la cuenta Efectivo. '
                      'El PIN de bloqueo también se quitará. Esta acción no se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Borrar todo'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;

                try {
                  await ref.read(appLockServiceProvider).clearPin();
                  await ref.read(authServiceProvider).clearAllUsers();
                  await ref.read(financeRepositoryProvider).resetAllUserData();
                  ref.invalidate(currentAuthUserProvider);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Datos borrados. Puedes empezar de cero.'),
                    ),
                  );
                  context.go('/onboarding');
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No se pudo borrar: $e')),
                    );
                  }
                }
              },
              child: Row(
                children: [
                  Icon(Icons.delete_forever_outlined,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Borrar todos los datos',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                        ),
                        Text(
                          'Empezar de cero en este dispositivo',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 120),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moneda',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _currencies.map((code) {
                      final selected = currency == code;
                      return ChoiceChip(
                        label: Text(
                          code,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : null,
                          ),
                        ),
                        selected: selected,
                        onSelected: (_) {
                          ref
                              .read(financeRepositoryProvider)
                              .setCurrencyCode(code);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: GlassCard(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kAppName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          'Datos guardados en tu dispositivo',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
              ],
            ),
          ),
          Center(
            child: AppCreditFooter(
              versionLabel: versionLabel,
              lightOnGradient: false,
            ),
          ),
        ],
      ),
    );
  }
}
