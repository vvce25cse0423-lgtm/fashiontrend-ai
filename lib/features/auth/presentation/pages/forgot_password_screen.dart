import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/glass_text_field.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  Future<void> _reset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).resetPassword(email);
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) AppSnackbar.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                const SizedBox(height: 40),

                if (!_sent) ...[
                  Text('Reset Password',
                      style: Theme.of(context).textTheme.headlineLarge)
                      .animate().slideX(begin: -0.3, duration: 500.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email to receive a password reset link.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fade(delay: 200.ms),
                  const SizedBox(height: 40),
                  GlassTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'you@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    onPressed: _isLoading ? null : _reset,
                    isLoading: _isLoading,
                    text: 'SEND RESET LINK',
                    gradient: AppTheme.goldGradient,
                    textColor: Colors.black,
                  ),
                ] else ...[
                  // Success state
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.successGreen.withOpacity(0.2),
                          ),
                          child: const Icon(Icons.check_circle_outline,
                              color: AppTheme.successGreen, size: 60),
                        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 24),
                        Text('Email Sent!',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        Text(
                          'Check your inbox for a password reset link.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 40),
                        GradientButton(
                          onPressed: () => context.pop(),
                          text: 'BACK TO LOGIN',
                          gradient: AppTheme.goldGradient,
                          textColor: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
