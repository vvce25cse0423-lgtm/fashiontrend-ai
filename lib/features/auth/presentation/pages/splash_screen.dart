import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../themes/app_theme.dart';
import '../../../../core/router/app_router.dart';

/// Splash screen shown on app launch
/// Handles navigation to onboarding or home based on auth state
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for animations
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    dynamic session;
    try { session = Supabase.instance.client.auth.currentSession; } catch (_) { session = null; }

    if (!mounted) return;

    if (session != null) {
      context.go(AppRoutes.home);
    } else if (!onboardingDone) {
      context.go(AppRoutes.onboarding);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0F), Color(0xFF1A0A2E), Color(0xFF0A0A0F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryGold.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentPurple.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.goldGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.black,
                      size: 50,
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1.0, 1.0),
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                      )
                      .fade(duration: 600.ms),

                  const SizedBox(height: 24),

                  // App name
                  Text(
                    'FashionTrend',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          foreground: Paint()
                            ..shader = AppTheme.goldGradient.createShader(
                              const Rect.fromLTWH(0, 0, 300, 60),
                            ),
                        ),
                  )
                      .animate()
                      .slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 700.ms,
                        delay: 300.ms,
                        curve: Curves.easeOut,
                      )
                      .fade(delay: 300.ms, duration: 700.ms),

                  Text(
                    'AI',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 28,
                          letterSpacing: 12,
                          fontWeight: FontWeight.w300,
                        ),
                  )
                      .animate()
                      .slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 700.ms,
                        delay: 500.ms,
                        curve: Curves.easeOut,
                      )
                      .fade(delay: 500.ms, duration: 700.ms),

                  const SizedBox(height: 12),

                  Text(
                    'Your Personal Style Intelligence',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.0,
                        ),
                  )
                      .animate()
                      .fade(delay: 800.ms, duration: 700.ms),

                  const SizedBox(height: 80),

                  // Loading indicator
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      backgroundColor: AppTheme.borderGlass,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGold,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                      .animate()
                      .fade(delay: 1000.ms, duration: 500.ms),
                ],
              ),
            ),

            // Bottom tagline
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'Powered by AI • Made for Style',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textSecondary.withOpacity(0.5),
                      letterSpacing: 2,
                    ),
              ).animate().fade(delay: 1200.ms, duration: 700.ms),
            ),
          ],
        ),
      ),
    );
  }
}
