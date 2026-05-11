import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the current Supabase session
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Returns the current user (null if not logged in)
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// Converts raw Supabase/API error messages into friendly user-facing text
String _friendlyError(String raw) {
  final msg = raw.toLowerCase();

  if (msg.contains('over_email_send_rate_limit') ||
      msg.contains('rate limit') ||
      msg.contains('request this after') ||
      msg.contains('429')) {
    // Parse seconds from message if possible e.g. "after 26 seconds"
    final match = RegExp(r'after (\d+) second').firstMatch(raw);
    final secs = match != null ? match.group(1) : 'a few';
    return 'Too many attempts. Please wait $secs seconds and try again.';
  }
  if (msg.contains('user already registered') ||
      msg.contains('email already')) {
    return 'This email is already registered. Please sign in instead.';
  }
  if (msg.contains('invalid login credentials') ||
      msg.contains('invalid email or password')) {
    return 'Incorrect email or password. Please try again.';
  }
  if (msg.contains('email not confirmed')) {
    return 'Please check your email and confirm your account first.';
  }
  if (msg.contains('weak password') || msg.contains('password should')) {
    return 'Password must be at least 6 characters.';
  }
  if (msg.contains('network') ||
      msg.contains('socket') ||
      msg.contains('connection')) {
    return 'No internet connection. Please check your network.';
  }
  if (msg.contains('invalid email')) {
    return 'Please enter a valid email address.';
  }
  // Strip internal class names from raw message before showing
  return raw
      .replaceAll(RegExp(r'AuthApiException\(.*?:\s*'), '')
      .replaceAll(RegExp(r',\s*statusCode:.*'), '')
      .replaceAll(RegExp(r',\s*code:.*'), '')
      .trim();
}

/// Auth controller for login/register/logout actions
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncValue.data(null));

  final _auth = Supabase.instance.client.auth;
  final _db = Supabase.instance.client;

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _auth.signInWithPassword(email: email, password: password);
      state = const AsyncValue.data(null);
    } on AuthException catch (e) {
      final friendly = _friendlyError(e.message);
      state = AsyncValue.error(friendly, StackTrace.current);
      throw Exception(friendly);
    } catch (e) {
      final friendly = _friendlyError(e.toString());
      state = AsyncValue.error(friendly, StackTrace.current);
      throw Exception(friendly);
    }
  }

  /// Create a new account
  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.user != null) {
        // Upsert so duplicate inserts don't crash
        await _db.from('profiles').upsert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      state = const AsyncValue.data(null);
    } on AuthException catch (e) {
      final friendly = _friendlyError(e.message);
      state = AsyncValue.error(friendly, StackTrace.current);
      throw Exception(friendly);
    } catch (e) {
      final friendly = _friendlyError(e.toString());
      state = AsyncValue.error(friendly, StackTrace.current);
      throw Exception(friendly);
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _auth.resetPasswordForEmail(email);
      state = const AsyncValue.data(null);
    } on AuthException catch (e) {
      final friendly = _friendlyError(e.message);
      state = AsyncValue.error(friendly, StackTrace.current);
      throw Exception(friendly);
    } catch (e) {
      final friendly = _friendlyError(e.toString());
      state = AsyncValue.error(friendly, StackTrace.current);
      throw Exception(friendly);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(),
);
