import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_finance_app/core/motion/fade_slide_in.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/ui/animated_gradient_background.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  Future<void> _tryBiometric() async {
    final lock = ref.read(appLockServiceProvider);
    if (!await lock.canUseBiometrics()) return;
    final ok = await lock.authenticateWithBiometrics();
    if (ok && mounted) context.go('/home');
  }

  Future<void> _submitPin() async {
    final lock = ref.read(appLockServiceProvider);
    final valid = await lock.validatePin(_pin);
    if (!mounted) return;
    if (valid) {
      context.go('/home');
    } else {
      setState(() {
        _error = 'PIN incorrecto';
        _pin = '';
      });
    }
  }

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _error = null;
      _pin += digit;
    });
    if (_pin.length == 4) _submitPin();
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      colors: AppColors.homeGradientFor(Theme.of(context).brightness),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                FadeSlideIn(
                  child: Column(
                    children: [
                      Icon(Icons.lock_rounded, size: 56, color: AppColors.teal),
                      const SizedBox(height: 16),
                      Text(
                        'Finanza bloqueada',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa tu PIN de 4 dígitos',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final filled = index < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      width: filled ? 18 : 14,
                      height: filled ? 18 : 14,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? AppColors.teal
                            : Colors.white.withValues(alpha: 0.15),
                      ),
                    );
                  }),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.expense)),
                ],
                const Spacer(),
                _PinPad(onDigit: _onDigit, onBackspace: _backspace),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _tryBiometric,
                  child: const Text('Usar biometría'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinPad extends StatelessWidget {
  const _PinPad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        if (key.isEmpty) return const SizedBox.shrink();
        return Material(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (key == '⌫') {
                onBackspace();
              } else {
                onDigit(key);
              }
            },
            child: Center(
              child: Text(
                key,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}
