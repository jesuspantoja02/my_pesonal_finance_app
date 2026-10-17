import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_finance_app/core/motion/app_page_transition.dart';
import 'package:my_personal_finance_app/features/auth/presentation/login_screen.dart';
import 'package:my_personal_finance_app/features/home/presentation/main_shell.dart';
import 'package:my_personal_finance_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:my_personal_finance_app/features/security/presentation/lock_screen.dart';
import 'package:my_personal_finance_app/features/splash/presentation/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/lock',
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const LockScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => fadeSlidePage(
          key: state.pageKey,
          child: const MainShell(),
        ),
      ),
    ],
  );
}
