import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/layout/main_shell_metrics.dart';
import 'package:my_personal_finance_app/core/motion/animated_pressable.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';

class MainShellBottomBar extends StatelessWidget {
  const MainShellBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onPrimaryAction,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback? onPrimaryAction;

  static String? labelForIndex(int index) {
    return switch (index) {
      0 || 1 => 'Nuevo movimiento',
      2 => 'Agregar nueva cuenta',
      3 => 'Nuevo préstamo',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final barColor = isLight
        ? AppColors.surfaceCardLight.withValues(alpha: 0.98)
        : AppColors.surfaceCard.withValues(alpha: 0.96);
    final actionLabel = labelForIndex(selectedIndex);
    final showAction = actionLabel != null && onPrimaryAction != null;

    return Material(
      color: barColor,
      elevation: isLight ? 8 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAction)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: AnimatedPressable(
                  onTap: onPrimaryAction,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: isLight
                            ? [AppColors.tealDark, AppColors.teal]
                            : [AppColors.teal, AppColors.emerald],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tealDark
                              .withValues(alpha: isLight ? 0.4 : 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: MainShellMetrics.actionButtonHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            actionLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            NavigationBar(
              height: 64,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.space_dashboard_outlined),
                  selectedIcon: Icon(Icons.space_dashboard),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Movimientos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet),
                  label: 'Cuentas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.handshake_outlined),
                  selectedIcon: Icon(Icons.handshake_rounded),
                  label: 'Préstamos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_outlined),
                  selectedIcon: Icon(Icons.tune),
                  label: 'Ajustes',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
