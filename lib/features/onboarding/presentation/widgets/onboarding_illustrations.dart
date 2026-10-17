import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';

class OnboardingWelcomeIllustration extends StatelessWidget {
  const OnboardingWelcomeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5EEAD4),
            Color(0xFF14B8A6),
            Color(0xFF0D9488),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -24,
            right: -16,
            child: _bubble(96, 0.12),
          ),
          Positioned(
            bottom: -28,
            left: -20,
            child: _bubble(80, 0.1),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  kAppName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.waving_hand_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class OnboardingHowToIllustration extends StatelessWidget {
  const OnboardingHowToIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF0FDFA),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        _StepChip(step: '1', label: 'Cuenta', done: true),
                        SizedBox(width: 6),
                        _StepChip(step: '2', label: 'Monto', done: true),
                        SizedBox(width: 6),
                        _StepChip(step: '3', label: 'Cat.', done: false),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nuevo movimiento',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textStrongLight,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 8),
                            _MockField(
                              text: 'Monto · Cuenta · Categoría',
                              icon: Icons.add_circle_outline,
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.touch_app_outlined,
                                  size: 16,
                                  color: AppColors.tealDark,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Botón + en Inicio',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMutedLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.step,
    required this.label,
    required this.done,
  });

  final String step;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor:
                done ? AppColors.teal : AppColors.surfaceElevatedLight,
            child: Text(
              step,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: done ? Colors.white : AppColors.textMutedLight,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _MockField extends StatelessWidget {
  const _MockField({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.tealDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textStrongLight,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingInsightsIllustration extends StatelessWidget {
  const OnboardingInsightsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFECFDF5),
            Color(0xFFD1FAE5),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _WalletBadge(label: 'Yape', color: const Color(0xFF6D28D9)),
                _WalletBadge(label: 'Plin', color: const Color(0xFF0369A1)),
                _WalletBadge(label: 'PEN', color: AppColors.tealDark),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _ChartCard(
                      child: CustomPaint(
                        painter: _MiniPiePainter(),
                        child: const Center(
                          child: Icon(
                            Icons.pie_chart_rounded,
                            color: AppColors.tealDark,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ChartCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.trending_up_rounded,
                            color: AppColors.income,
                            size: 28,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Tendencia',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMutedLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Respaldo local en tu celular',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMutedLight,
                fontWeight: FontWeight.w600,
              ),
            ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WalletBadge extends StatelessWidget {
  const _WalletBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MiniPiePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.28;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    const segments = [
      (AppColors.teal, 0.0, 2.2),
      (AppColors.emerald, 2.2, 1.4),
      (AppColors.expense, 3.6, 1.0),
    ];
    for (final (color, start, sweep) in segments) {
      paint.color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
