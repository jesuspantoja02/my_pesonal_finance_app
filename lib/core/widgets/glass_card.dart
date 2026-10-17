import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/motion/animated_pressable.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isLight = !context.isFinanceDark;
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isLight ? 6 : 12,
          sigmaY: isLight ? 6 : 12,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: context.financeCardFill,
            border: Border.all(color: context.financeBorder, width: isLight ? 1.2 : 1),
            boxShadow: [
              BoxShadow(
                color: isLight
                    ? Colors.black.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.12),
                blurRadius: isLight ? 14 : 20,
                offset: Offset(0, isLight ? 6 : 10),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap == null && onLongPress == null) return card;
    return AnimatedPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(24),
      child: card,
    );
  }
}
