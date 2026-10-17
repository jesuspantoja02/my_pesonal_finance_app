import 'package:flutter/material.dart';

Future<T?> showFinanceBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Theme(
        data: Theme.of(sheetContext),
        child: builder(sheetContext),
      );
    },
  );
}
