import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_personal_finance_app/core/constants/app_config.dart';
import 'package:my_personal_finance_app/core/motion/fade_slide_in.dart';
import 'package:my_personal_finance_app/core/providers/app_providers.dart';
import 'package:my_personal_finance_app/core/services/auth_service.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/ui/animated_gradient_background.dart';
import 'package:my_personal_finance_app/core/widgets/app_credit_footer.dart';
import 'package:my_personal_finance_app/features/auth/presentation/widgets/social_sign_in_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isRegister = false;
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _goToApp() async {
    final prefs = await ref.read(financeRepositoryProvider).getAppPreferences();
    if (!mounted) return;
    if (prefs.appLockEnabled) {
      context.go('/lock');
    } else {
      context.go('/home');
    }
  }

  Future<void> _afterSocialSignIn() async {
    if (!mounted) return;
    ref.invalidate(currentAuthUserProvider);
    await _goToApp();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      await _afterSocialSignIn();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'No se pudo iniciar con Google. $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithApple();
      await _afterSocialSignIn();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'No se pudo iniciar con Apple. $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      if (_isRegister) {
        await auth.register(
          displayName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await auth.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (!mounted) return;
      ref.invalidate(currentAuthUserProvider);
      await _goToApp();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'No se pudo completar. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegister = !_isRegister;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final versionLabel = ref.watch(appVersionLabelProvider);
    final firebaseReady =
        ref.watch(firebaseReadyProvider).valueOrNull ?? false;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedGradientBackground(
      colors: AppColors.splashGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) context.go('/onboarding');
          },
          child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.go('/onboarding'),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    label: Text(
                      'Volver',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                FadeSlideIn(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'finanza-logo',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        kAppName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isRegister
                            ? 'Crea tu cuenta (correo, Google o Apple)'
                            : 'Inicia sesión para continuar',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isRegister ? 'Crear cuenta' : 'Iniciar sesión',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 18),
                            if (_isRegister) ...[
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre',
                                  hintText: 'Ej. Jesús',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (v) {
                                  if ((v ?? '').trim().isEmpty) {
                                    return 'Escribe tu nombre';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                            ],
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                hintText: 'tu@correo.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) {
                                final email = (v ?? '').trim();
                                if (email.isEmpty) {
                                  return 'Ingresa tu correo';
                                }
                                if (!email.contains('@')) {
                                  return 'Correo no válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                hintText: _isRegister
                                    ? 'Mínimo 6 caracteres'
                                    : 'Tu contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if ((v ?? '').isEmpty) {
                                  return 'Ingresa tu contraseña';
                                }
                                if (_isRegister && (v!.length < 6)) {
                                  return 'Mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            FilledButton(
                              onPressed: _loading ? null : _submit,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                backgroundColor: AppColors.teal,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isRegister
                                          ? 'Registrarme'
                                          : 'Iniciar sesión',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _loading ? null : _toggleMode,
                              child: Text(
                                _isRegister
                                    ? '¿Ya tienes cuenta? Inicia sesión'
                                    : '¿Primera vez? Crear cuenta',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: context.financeMuted,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: context.financeMuted),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    'o continúa con',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: context.financeMuted),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: context.financeMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SocialSignInButtons(
                              loading: _loading || !firebaseReady,
                              onGoogle: _signInWithGoogle,
                              onApple: _signInWithApple,
                            ),
                            if (!firebaseReady) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Conectando con Google y Apple…',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.financeMuted,
                                    ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Text(
                              'Tus movimientos y cuentas quedan solo en este '
                              'dispositivo. En la nube guardamos únicamente tu '
                              'registro y último acceso (sin montos ni transacciones).',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.financeMuted,
                                    height: 1.35,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AppCreditFooter(
                  versionLabel: versionLabel,
                  lightOnGradient: true,
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
