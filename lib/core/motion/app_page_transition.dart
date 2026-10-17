import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_finance_app/core/motion/app_motion.dart';

CustomTransitionPage<T> fadeSlidePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: AppMotion.emphasis,
    reverseTransitionDuration: AppMotion.standard,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.easeOut,
        reverseCurve: AppMotion.easeIn,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: AppMotion.slideRoute,
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

Widget tabSwitchTransition(
  Widget child,
  Animation<double> animation,
  int fromIndex,
  int toIndex,
) {
  final goingRight = toIndex >= fromIndex;
  final curved = CurvedAnimation(parent: animation, curve: AppMotion.easeOut);
  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: Offset(goingRight ? 0.06 : -0.06, 0),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}
