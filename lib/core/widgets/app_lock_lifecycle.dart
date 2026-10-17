import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/routing/app_router.dart';

/// Sends the user to the lock screen when returning from background.
class AppLockLifecycle extends ConsumerStatefulWidget {
  const AppLockLifecycle({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockLifecycle> createState() => _AppLockLifecycleState();
}

class _AppLockLifecycleState extends ConsumerState<AppLockLifecycle>
    with WidgetsBindingObserver {
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasBackgrounded = true;
      return;
    }
    if (state != AppLifecycleState.resumed || !_wasBackgrounded) return;
    _wasBackgrounded = false;

    final lockEnabled =
        ref.read(appPreferencesProvider).valueOrNull?.appLockEnabled ?? false;
    if (!lockEnabled) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    final location = GoRouter.of(context).state.uri.path;
    if (location == '/lock' || location == '/' || location == '/onboarding') {
      return;
    }

    context.go('/lock');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
