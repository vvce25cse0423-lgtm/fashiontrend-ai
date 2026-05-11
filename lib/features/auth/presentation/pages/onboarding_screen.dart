import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../themes/app_theme.dart';
import '../../../../core/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardingPage(
      icon: Icons.face_retouching_natural,
      gradient: AppTheme.goldGradient,
      title: 'AI Selfie Analysis',
      subtitle: 'Upload your photo and let AI detect your face shape, skin tone, and body type in seconds.',
      bgColor: const Color(0xFF1A1200),
    ),
    _OnboardingPage(
      icon: Icons.checkroom,
      gradient: AppTheme.purpleGradient,
      title: 'Smart Outfit Generator',
      subtitle: 'Get personalized outfit recommendations based on weather, occasion, and your style.',
      bgColor: const Color(0xFF0E0A1E),
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome,
      gradient: LinearGradient(
        colors: [AppTheme.accentPink, Color(0xFFFF6B6B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      title: 'Complete Style AI',
      subtitle: 'Shoes, watches, perfume, hairstyle — your complete fashion universe, powered by AI.',
      bgColor: const Color(0xFF1A0A0A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _buildPage(context, page);
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.darkBg],
                ),
              ),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotColor: AppTheme.borderGlass,
                      activeDotColor: AppTheme.primaryGold,
                      dotHeight: 6,
                      dotWidth: 6,
                      expansionFactor: 4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next / Get Started button
                  GestureDetector(
                    onTap: () async {
                      if (_currentPage < _pages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('onboarding_done', true);
                        if (context.mounted) context.go(AppRoutes.login);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: _currentPage == _pages.length - 1
                            ? AppTheme.goldGradient
                            : const LinearGradient(
                                colors: [
                                  AppTheme.surfaceBg,
                                  AppTheme.cardBg,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _currentPage == _pages.length - 1
                              ? Colors.transparent
                              : AppTheme.borderGlass,
                        ),
                        boxShadow: _currentPage == _pages.length - 1
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'GET STARTED'
                              : 'NEXT',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: _currentPage == _pages.length - 1
                                    ? Colors.black
                                    : AppTheme.textPrimary,
                                fontSize: 16,
                                letterSpacing: 2,
                              ),
                        ),
                      ),
                    ),
                  ),

                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('onboarding_done', true);
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                      child: Text(
                        'Skip',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, _OnboardingPage page) {
    return Container(
      color: page.bgColor,
      child: Column(
        children: [
          // Icon area
          Expanded(
            flex: 6,
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: page.gradient,
                  boxShadow: [
                    BoxShadow(
                      color: (page.gradient.colors.first).withOpacity(0.3),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  page.icon,
                  size: 90,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fade(duration: 400.ms),
            ),
          ),

          // Text area
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          foreground: Paint()
                            ..shader = page.gradient.createShader(
                              const Rect.fromLTWH(0, 0, 300, 50),
                            ),
                        ),
                  ).animate().slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 500.ms,
                        delay: 200.ms,
                      ),
                  const SizedBox(height: 16),
                  Text(
                    page.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                  ).animate().fade(delay: 400.ms, duration: 500.ms),
                ],
              ),
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String subtitle;
  final Color bgColor;

  const _OnboardingPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.bgColor,
  });
}
