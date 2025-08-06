import 'package:firebase_auth/firebase_auth.dart';

/// Custom exception class for authentication errors
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, [this.code]);

  /// Create AuthException from FirebaseAuthException
  factory AuthException.fromFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException(
            'No user found for that email.', 'user-not-found');
      case 'wrong-password':
        return const AuthException(
            'Wrong password provided for that user.', 'wrong-password');
      case 'email-already-in-use':
        return const AuthException('The account already exists for that email.',
            'email-already-in-use');
      case 'weak-password':
        return const AuthException(
            'The password provided is too weak.', 'weak-password');
      case 'invalid-email':
        return const AuthException(
            'The email address is not valid.', 'invalid-email');
      case 'user-disabled':
        return const AuthException(
            'This user account has been disabled.', 'user-disabled');
      case 'too-many-requests':
        return const AuthException(
            'Too many requests. Try again later.', 'too-many-requests');
      case 'operation-not-allowed':
        return const AuthException(
            'Operation not allowed.', 'operation-not-allowed');
      case 'requires-recent-login':
        return const AuthException(
            'This operation requires recent authentication.',
            'requires-recent-login');
      case 'network-request-failed':
        return const AuthException(
            'Network error. Please check your connection.',
            'network-request-failed');
      case 'invalid-verification-code':
        return const AuthException(
            'Invalid verification code.', 'invalid-verification-code');
      case 'invalid-verification-id':
        return const AuthException(
            'Invalid verification ID.', 'invalid-verification-id');
      case 'session-expired':
        return const AuthException(
            'Session expired. Please sign in again.', 'session-expired');
      default:
        return AuthException(e.message ?? 'An unknown error occurred.', e.code);
    }
  }

  @override
  String toString() => 'AuthException: $message';
}

/// Custom exception class for database errors
class DatabaseException implements Exception {
  final String message;
  final String? code;

  const DatabaseException(this.message, [this.code]);

  @override
  String toString() => 'DatabaseException: $message';
}

/// Custom exception class for storage errors
class StorageException implements Exception {
  final String message;
  final String? code;

  const StorageException(this.message, [this.code]);

  @override
  String toString() => 'StorageException: $message';
}

/// Custom exception class for network errors
class NetworkException implements Exception {
  final String message;
  final String? code;

  const NetworkException(this.message, [this.code]);

  @override
  String toString() => 'NetworkException: $message';
}

/// Custom exception class for validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationException(this.message, [this.fieldErrors]);

  @override
  String toString() => 'ValidationException: $message';
}

/// Custom exception class for permission errors
class PermissionException implements Exception {
  final String message;
  final String? requiredPermission;

  const PermissionException(this.message, [this.requiredPermission]);

  @override
  String toString() => 'PermissionException: $message';
}

/// Custom exception class for business logic errors
class BusinessLogicException implements Exception {
  final String message;
  final String? code;

  const BusinessLogicException(this.message, [this.code]);

  @override
  String toString() => 'BusinessLogicException: $message';
}

/// Custom exception class for location errors
class LocationException implements Exception {
  final String message;
  final String? code;

  const LocationException(this.message, [this.code]);

  @override
  String toString() => 'LocationException: $message';
}

/// Custom exception class for biometric authentication errors
class BiometricException implements Exception {
  final String message;
  final String? code;

  const BiometricException(this.message, [this.code]);

  @override
  String toString() => 'BiometricException: $message';
}

/// Helper class for handling and formatting exceptions
class ExceptionHandler {
  /// Get user-friendly error message from exception
  static String getUserFriendlyMessage(Exception exception) {
    if (exception is AuthException) {
      return exception.message;
    } else if (exception is DatabaseException) {
      return 'Database error: ${exception.message}';
    } else if (exception is StorageException) {
      return 'Storage error: ${exception.message}';
    } else if (exception is NetworkException) {
      return 'Network error: ${exception.message}';
    } else if (exception is ValidationException) {
      return 'Validation error: ${exception.message}';
    } else if (exception is PermissionException) {
      return 'Permission error: ${exception.message}';
    } else if (exception is BusinessLogicException) {
      return exception.message;
    } else if (exception is LocationException) {
      return 'Location error: ${exception.message}';
    } else if (exception is BiometricException) {
      return 'Biometric authentication error: ${exception.message}';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Check if exception is network related
  static bool isNetworkError(Exception exception) {
    return exception is NetworkException ||
        (exception is AuthException &&
            exception.code == 'network-request-failed');
  }

  /// Check if exception requires user authentication
  static bool requiresAuthentication(Exception exception) {
    return exception is AuthException &&
        (exception.code == 'requires-recent-login' ||
            exception.code == 'session-expired' ||
            exception.code == 'user-not-found');
  }

  /// Check if exception is due to insufficient permissions
  static bool isPermissionError(Exception exception) {
    return exception is PermissionException ||
        (exception is AuthException &&
            exception.code == 'operation-not-allowed');
  }
}
