import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/motion/animated_pressable.dart';
import 'package:my_personal_finance_app/core/ui/brand_logos.dart';

class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({
    super.key,
    required this.loading,
    required this.onGoogle,
    required this.onApple,
  });

  final bool loading;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  bool get _showApple {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS ||
      TargetPlatform.android ||
      TargetPlatform.macOS =>
        true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BrandButton(
          onPressed: loading ? null : onGoogle,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F1F1F),
          borderColor: const Color(0xFFDADCE0),
          icon: const GoogleLogo(size: 20),
          label: 'Continuar con Google',
        ),
        if (_showApple) ...[
          const SizedBox(height: 10),
          _BrandButton(
            onPressed: loading ? null : onApple,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            borderColor: Colors.black,
            icon: const AppleLogo(size: 22),
            label: 'Continuar con Apple',
          ),
        ],
      ],
    );
  }
}

class _BrandButton extends StatelessWidget {
  const _BrandButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      enabled: onPressed != null,
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
