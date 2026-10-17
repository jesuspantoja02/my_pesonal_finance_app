import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_finance_app/core/motion/app_motion.dart';
import 'package:my_personal_finance_app/core/motion/fade_slide_in.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/ui/animated_gradient_background.dart';
import 'package:my_personal_finance_app/core/widgets/app_credit_footer.dart';
import 'package:my_personal_finance_app/features/onboarding/presentation/widgets/onboarding_illustrations.dart';
import 'package:my_personal_finance_app/features/onboarding/presentation/widgets/onboarding_slide_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _controller;
  int _page = 0;

  static const _slideCount = 3;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
  }

  void _goToLogin() {
    context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  OnboardingSlideCard _slideAt(int index, double illustrationHeight) {
    return switch (index) {
      0 => OnboardingSlideCard(
          illustrationHeight: illustrationHeight,
          illustration: const OnboardingWelcomeIllustration(),
          accent: 'Bienvenida',
          title: '¡Hola! Esta es Finanza',
          body:
              'Tu app personal para organizar efectivo, billeteras y tarjetas. '
              'Sin datos de ejemplo: tú empiezas en blanco.',
        ),
      1 => OnboardingSlideCard(
          illustrationHeight: illustrationHeight,
          illustration: const OnboardingHowToIllustration(),
          accent: 'Cómo usarla',
          title: 'Registra en segundos',
          body:
              'En Inicio pulsa + y anota un gasto o ingreso. Elige cuenta, '
              'monto y categoría para ver tu saldo al día.',
        ),
      _ => OnboardingSlideCard(
          illustrationHeight: illustrationHeight,
          illustration: const OnboardingInsightsIllustration(),
          accent: 'Para ti en Perú',
          title: 'Entiende y protege tu plata',
          body:
              'Gráficos, presupuestos, Yape y Plin como cuentas, exportar CSV '
              'y respaldo JSON. Todo en tu dispositivo.',
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final versionLabel = ref.watch(appVersionLabelProvider);

    return AnimatedGradientBackground(
      colors: AppColors.splashGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final illustrationHeight =
                  (constraints.maxHeight * 0.28).clamp(160.0, 200.0);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: FadeSlideIn(
                            child: Text(
                              'Conoce Finanza',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _goToLogin,
                          child: Text(
                            'Saltar',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _slideCount,
                      onPageChanged: (index) => setState(() => _page = index),
                      itemBuilder: (context, index) {
                        return Align(
                          alignment: Alignment.center,
                          child: _slideAt(index, illustrationHeight),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slideCount,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _page == index ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: _page == index ? 0.95 : 0.35,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FilledButton(
                      onPressed: () {
                        if (_page < _slideCount - 1) {
                          _controller.nextPage(
                            duration: AppMotion.emphasis,
                            curve: AppMotion.easeOut,
                          );
                    } else {
                      _goToLogin();
                    }
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.tealDark,
                      ),
                      child: Text(
                        _page < _slideCount - 1 ? 'Siguiente' : 'Comenzar',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 6),
                    child: AppCreditFooter(
                      versionLabel: versionLabel,
                      lightOnGradient: true,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
