import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_finance_app/core/cloud/firebase_bootstrap.dart';
import 'package:my_personal_finance_app/core/motion/app_motion.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/widgets/app_credit_footer.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _goNext();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    try {
      await Future.wait([
        FirebaseBootstrap.tryInitialize(),
        Future<void>.delayed(AppMotion.splashHold),
      ]);
      if (!mounted) return;

      await ref
          .read(bootstrapProvider.future)
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;

      final hasSession = await ref
          .read(authServiceProvider)
          .hasActiveSession()
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;

      if (!hasSession) {
        context.go('/onboarding');
        return;
      }

      final prefs = await ref
          .read(financeRepositoryProvider)
          .getAppPreferences()
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;

      if (prefs.appLockEnabled) {
        context.go('/lock');
      } else {
        context.go('/home');
      }
    } catch (e, st) {
      debugPrint('Finanza: splash no pudo continuar: $e\n$st');
      if (!mounted) return;
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(bootstrapProvider);
    final versionLabel = ref.watch(appVersionLabelProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.splashGradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.96, end: 1.04).animate(
                          CurvedAnimation(
                            parent: _pulse,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Hero(
                          tag: 'finanza-logo',
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.28),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                              image: const DecorationImage(
                                image: AssetImage('assets/icon/app_icon.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Finanza',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tu dinero, bajo control',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: AppCreditFooter(
                  versionLabel: versionLabel,
                  lightOnGradient: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
