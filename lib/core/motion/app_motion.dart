import 'package:flutter/animation.dart';

/// Tokens de movimiento (fintech: corto, suave, predecible).
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration standard = Duration(milliseconds: 340);
  static const Duration emphasis = Duration(milliseconds: 480);
  static const Duration splashHold = Duration(milliseconds: 350);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve emphasized = Curves.easeOutExpo;
  static const Curve springy = Curves.easeOutBack;

  static const double pressScale = 0.97;
  static const Offset slideIn = Offset(0, 0.04);
  static const Offset slideRoute = Offset(0.06, 0);
}
