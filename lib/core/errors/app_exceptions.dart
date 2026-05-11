/// Base app exception
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Auth-specific exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

/// Parses Supabase/generic error messages into user-friendly text
String parseErrorMessage(dynamic error) {
  final msg = error.toString().toLowerCase();

  if (msg.contains('invalid login credentials') || msg.contains('invalid email or password')) {
    return 'Incorrect email or password. Please try again.';
  }
  if (msg.contains('email already registered') || msg.contains('user already registered')) {
    return 'This email is already registered. Please sign in.';
  }
  if (msg.contains('email not confirmed')) {
    return 'Please confirm your email before signing in.';
  }
  if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
    return 'Network error. Please check your connection.';
  }
  if (msg.contains('too many requests') || msg.contains('rate limit')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  if (msg.contains('weak password') || msg.contains('password should')) {
    return 'Password must be at least 6 characters.';
  }

  return 'Something went wrong. Please try again.';
}
