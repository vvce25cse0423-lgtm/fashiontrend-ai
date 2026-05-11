import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../themes/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/glass_text_field.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Rate limit cooldown
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    setState(() => _cooldownSeconds = seconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldownSeconds <= 1) {
        t.cancel();
        if (mounted) setState(() => _cooldownSeconds = 0);
      } else {
        if (mounted) setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cooldownSeconds > 0) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
      if (mounted) {
        AppSnackbar.success(
            context, '✅ Account created! Check your email to confirm.');
        context.go(AppRoutes.login);
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (mounted) {
        AppSnackbar.error(context, msg);
        // Parse cooldown seconds from message
        final match = RegExp(r'wait (\d+) second').firstMatch(msg);
        if (match != null) {
          _startCooldown(int.parse(match.group(1)!));
        } else if (msg.toLowerCase().contains('wait')) {
          _startCooldown(30);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCoolingDown = _cooldownSeconds > 0;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const SizedBox(height: 20),

                  Text('Create Account',
                      style: Theme.of(context).textTheme.headlineLarge)
                      .animate().slideX(begin: -0.3, duration: 500.ms),

                  const SizedBox(height: 8),
                  Text(
                    'Join the AI-powered fashion revolution',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fade(delay: 200.ms),

                  const SizedBox(height: 40),

                  GlassTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Your Name',
                    prefixIcon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Name is required' : null,
                  ).animate().slideY(begin: 0.3, delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  GlassTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'you@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ).animate().slideY(begin: 0.3, delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  GlassTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ).animate().slideY(begin: 0.3, delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 36),

                  // Cooldown warning banner
                  if (isCoolingDown) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.errorRed.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: AppTheme.errorRed, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Too many attempts. Please wait $_cooldownSeconds seconds before trying again.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppTheme.errorRed),
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake(),
                  ],

                  GradientButton(
                    onPressed: (_isLoading || isCoolingDown) ? null : _register,
                    isLoading: _isLoading,
                    text: isCoolingDown
                        ? 'WAIT ${_cooldownSeconds}s...'
                        : 'CREATE ACCOUNT',
                    gradient: AppTheme.goldGradient,
                    textColor: Colors.black,
                  ).animate().slideY(begin: 0.3, delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 28),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ',
                            style: Theme.of(context).textTheme.bodyMedium),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Sign In',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.primaryGold,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 500.ms),

                  const SizedBox(height: 20),

                  // Info tip about email confirmation
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.primaryGold.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppTheme.primaryGold, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'After signing up, check your email inbox for a confirmation link before signing in.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: AppTheme.primaryGold,
                                    height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 600.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
