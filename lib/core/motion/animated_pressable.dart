import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_personal_finance_app/core/motion/app_motion.dart';

/// Escala al tocar + haptic ligero. Usar en cards y CTAs.
class AnimatedPressable extends StatefulWidget {
  const AnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.haptic = true,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool haptic;
  final BorderRadius? borderRadius;

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final interactive =
        widget.enabled && (widget.onTap != null || widget.onLongPress != null);

    return GestureDetector(
      onTapDown: interactive ? (_) => _setPressed(true) : null,
      onTapUp: interactive ? (_) => _setPressed(false) : null,
      onTapCancel: interactive ? () => _setPressed(false) : null,
      onTap: widget.enabled && widget.onTap != null
          ? () {
              if (widget.haptic) {
                HapticFeedback.selectionClick();
              }
              widget.onTap!();
            }
          : null,
      onLongPress: widget.enabled && widget.onLongPress != null
          ? () {
              if (widget.haptic) {
                HapticFeedback.mediumImpact();
              }
              widget.onLongPress!();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? AppMotion.pressScale : 1,
        duration: AppMotion.instant,
        curve: AppMotion.easeOut,
        child: widget.child,
      ),
    );
  }
}
