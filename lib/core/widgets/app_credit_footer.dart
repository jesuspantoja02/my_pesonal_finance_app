import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';

class AppCreditFooter extends StatelessWidget {
  const AppCreditFooter({
    super.key,
    required this.versionLabel,
    this.lightOnGradient = true,
  });

  final String versionLabel;
  final bool lightOnGradient;

  @override
  Widget build(BuildContext context) {
    final muted = lightOnGradient
        ? Colors.white.withValues(alpha: 0.75)
        : context.financeMuted;
    final strong = lightOnGradient
        ? Colors.white.withValues(alpha: 0.92)
        : Theme.of(context).textTheme.bodySmall?.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Versión $versionLabel',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Creado por $kAppAuthor',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: strong,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
