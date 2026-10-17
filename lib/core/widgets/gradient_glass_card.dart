import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';

class GradientGlassCard extends StatelessWidget {
  const GradientGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  AppColors.tealDark.withValues(alpha: 0.16),
                  AppColors.emerald.withValues(alpha: 0.1),
                  AppColors.surfaceCardLight.withValues(alpha: 0.92),
                ]
              : [
                  AppColors.teal.withValues(alpha: 0.35),
                  AppColors.emerald.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.04),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.tealDark.withValues(alpha: isLight ? 0.12 : 0.15),
            blurRadius: isLight ? 16 : 24,
            offset: Offset(0, isLight ? 8 : 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isLight
                    ? AppColors.borderLight
                    : Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: card,
      ),
    );
  }
}
