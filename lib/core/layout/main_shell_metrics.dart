import 'package:flutter/material.dart';

/// Layout metrics for [MainShell] scrollable tabs.
abstract final class MainShellMetrics {
  static const double actionButtonHeight = 52;
  static const double contentExtraGap = 20;

  static double contentBottomPadding(BuildContext context) {
    return contentExtraGap;
  }
}
