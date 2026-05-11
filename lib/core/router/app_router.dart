import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/home/presentation/pages/main_shell.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/analysis/presentation/pages/upload_photo_screen.dart';
import '../../features/analysis/presentation/pages/ai_analysis_screen.dart';
import '../../features/recommendations/presentation/pages/outfit_recommendation_screen.dart';
import '../../features/recommendations/presentation/pages/accessories_screen.dart';
import '../../features/recommendations/presentation/pages/fashion_score_screen.dart';
import '../../features/closet/presentation/pages/virtual_closet_screen.dart';
import '../../features/closet/presentation/pages/saved_looks_screen.dart';
import '../../features/chatbot/presentation/pages/chatbot_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const uploadPhoto = '/upload-photo';
  static const aiAnalysis = '/ai-analysis';
  static const outfitRecommendation = '/outfit-recommendation';
  static const accessories = '/accessories';
  static const fashionScore = '/fashion-score';
  static const virtualCloset = '/virtual-closet';
  static const savedLooks = '/saved-looks';
  static const chatbot = '/chatbot';
  static const profile = '/profile';
  static const settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // Safe Supabase session check — won't crash if not initialized
      bool isLoggedIn = false;
      try {
        final session = Supabase.instance.client.auth.currentSession;
        isLoggedIn = session != null;
      } catch (_) {
        isLoggedIn = false;
      }

      final loc = state.matchedLocation;
      final isAuthRoute = loc == AppRoutes.login ||
          loc == AppRoutes.register ||
          loc == AppRoutes.onboarding ||
          loc == AppRoutes.splash ||
          loc == AppRoutes.forgotPassword;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.virtualCloset,
            builder: (context, state) => const VirtualClosetScreen(),
          ),
          GoRoute(
            path: AppRoutes.savedLooks,
            builder: (context, state) => const SavedLooksScreen(),
          ),
          GoRoute(
            path: AppRoutes.chatbot,
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.uploadPhoto,
        builder: (context, state) => const UploadPhotoScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiAnalysis,
        builder: (context, state) => AiAnalysisScreen(
          imagePath: state.extra as String?,
        ),
      ),
      GoRoute(
        path: AppRoutes.outfitRecommendation,
        builder: (context, state) => const OutfitRecommendationScreen(),
      ),
      GoRoute(
        path: AppRoutes.accessories,
        builder: (context, state) => const AccessoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.fashionScore,
        builder: (context, state) => const FashionScoreScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
