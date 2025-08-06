import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/exceptions.dart';

// Authentication Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSignInWithPhoneRequested extends AuthEvent {
  final String phoneNumber;
  final String smsCode;
  final String verificationId;

  const AuthSignInWithPhoneRequested({
    required this.phoneNumber,
    required this.smsCode,
    required this.verificationId,
  });

  @override
  List<Object> get props => [phoneNumber, smsCode, verificationId];
}

class AuthPhoneVerificationRequested extends AuthEvent {
  final String phoneNumber;

  const AuthPhoneVerificationRequested({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {}

// Aliases for consistent naming across the app
class AuthLoginRequested extends AuthSignInRequested {
  const AuthLoginRequested({
    required super.email,
    required super.password,
    this.rememberMe = false,
  });

  final bool rememberMe;

  @override
  List<Object> get props => [email, password, rememberMe];
}

class AuthLogoutRequested extends AuthSignOutRequested {}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthBiometricRequested extends AuthBiometricSignInRequested {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthPasswordUpdateRequested extends AuthEvent {
  final String newPassword;

  const AuthPasswordUpdateRequested({required this.newPassword});

  @override
  List<Object> get props => [newPassword];
}

class AuthBiometricSignInRequested extends AuthEvent {}

class AuthUserRefreshRequested extends AuthEvent {}

// Authentication States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final UserModel? userModel;
  final List<UserRole> roles;

  const AuthAuthenticated({
    required this.user,
    this.userModel,
    this.roles = const [UserRole.employee],
  });

  @override
  List<Object?> get props => [user, userModel, roles];
}

class AuthUnauthenticated extends AuthState {}

class AuthPhoneVerificationSent extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const AuthPhoneVerificationSent({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [verificationId, phoneNumber];
}

class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthPasswordUpdated extends AuthState {}

class AuthBiometricAvailable extends AuthState {
  final bool isAvailable;

  const AuthBiometricAvailable({required this.isAvailable});

  @override
  List<Object> get props => [isAvailable];
}

// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignInWithPhoneRequested>(_onSignInWithPhoneRequested);
    on<AuthPhoneVerificationRequested>(_onPhoneVerificationRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthPasswordUpdateRequested>(_onPasswordUpdateRequested);
    on<AuthBiometricSignInRequested>(_onBiometricSignInRequested);
    on<AuthUserRefreshRequested>(_onUserRefreshRequested);

    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        add(AuthUserRefreshRequested());
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onAuthStarted(
      AuthStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userModel = await _authService.getUserDocument(user.uid);
        final roles = await _authService.getUserRoles();

        emit(AuthAuthenticated(
          user: user,
          userModel: userModel,
          roles: roles,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(
          message: ExceptionHandler.getUserFriendlyMessage(e as Exception)));
    }
  }

  Future<void> _onSignInRequested(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Check if account is locked
      final isLocked = await _authService.isAccountLocked(event.email);
      if (isLocked) {
        emit(const AuthError(
          message:
              'Account is temporarily locked due to multiple failed login attempts',
          code: 'account-locked',
        ));
        return;
      }

      final credential = await _authService.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential.user != null) {
        // Reset failed login attempts on successful login
        await _authService.resetFailedLoginAttempts(credential.user!.uid);

        final userModel =
            await _authService.getUserDocument(credential.user!.uid);
        final roles = await _authService.getUserRoles();

        emit(AuthAuthenticated(
          user: credential.user!,
          userModel: userModel,
          roles: roles,
        ));
      }
    } catch (e) {
      // Record failed login attempt
      await _authService.recordFailedLoginAttempt(event.email);

      if (e is AuthException) {
        emit(AuthError(message: e.message, code: e.code));
      } else {
        emit(AuthError(
            message: ExceptionHandler.getUserFriendlyMessage(e as Exception)));
      }
    }
  }

  Future<void> _onSignInWithPhoneRequested(
    AuthSignInWithPhoneRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final credential = await _authService.signInWithPhoneNumber(
        phoneNumber: event.phoneNumber,
        smsCode: event.smsCode,
        verificationId: event.verificationId,
      );

      if (credential.user != null) {
        final userModel =
            await _authService.getUserDocument(credential.user!.uid);
        final roles = await _authService.getUserRoles();

        emit(AuthAuthenticated(
          user: credential.user!,
          userModel: userModel,
          roles: roles,
        ));
      }
    } catch (e) {
      if (e is AuthException) {
        emit(AuthError(message: e.message, code: e.code));
      } else {
        emit(AuthError(
            message: ExceptionHandler.getUserFriendlyMessage(e as Exception)));
      }
    }
  }

  Future<void> _onPhoneVerificationRequested(
    AuthPhoneVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Format Sri Lankan phone number
      final formattedPhone =
          _authService.formatSriLankanPhoneNumber(event.phoneNumber);

      if (!_authService.isValidSriLankanPhoneNumber(formattedPhone)) {
        emit(const AuthError(
          message: 'Please enter a valid Sri Lankan phone number',
          code: 'invalid-phone-number',
        ));
        return;
      }

      await _authService.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          try {
            final userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            if (userCredential.user != null) {
              final userModel =
                  await _authService.getUserDocument(userCredential.user!.uid);
              final roles = await _authService.getUserRoles();

              emit(AuthAuthenticated(
                user: userCredential.user!,
                userModel: userModel,
                roles: roles,
              ));
            }
          } catch (e) {
            emit(AuthError(message: 'Auto-verification failed: $e'));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthError(
            message: 'Verification failed: ${e.message}',
            code: e.code,
          ));
        },
        codeSent: (String verificationId, int? resendToken) {
          emit(AuthPhoneVerificationSent(
            verificationId: verificationId,
            phoneNumber: formattedPhone,
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout if needed
        },
      );
    } catch (e) {
      if (e is AuthException) {
        emit(AuthError(message: e.message, code: e.code));
      } else {
        emit(AuthError(
            message: ExceptionHandler.getUserFriendlyMessage(e as Exception)));
      }
    }
  }

  Future<void> _onSignUpRequested(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final credential = await _authService.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential.user != null) {
        // Send email verification
        await _authService.sendEmailVerification();

        final userModel =
            await _authService.getUserDocument(credential.user!.uid);
        final roles = await _authService.getUserRoles();

        emit(AuthAuthenticated(
          user: credential.user!,
          userModel: userModel,
          roles: roles,
        ));
      }
    } catch (e) {
      if (e is AuthException) {
        emit(AuthError(message: e.message, code: e.code));
      } else {
        emit(AuthError(
            message: ExceptionHandler.getUserFriendlyMessage(e as Exception)));
      }
    }
  }

  Future<void> _onGoogleSignInRequested(
      AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Temporarily emit error until Google Sign-In is properly implemented
      emit(const AuthError(
        message: 'Google Sign-In is not yet implemented',
        code: 'not-implemented',
      ));
    } catch (e) {
      emit(AuthError(
          message: ExceptionHandler.getUserFriendlyMessage(e as Exception)));
    }
  }

  Future<void> _onSignOutRequested(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(
          message: ExceptionHandler.getUserFriendlyMessage(e as Exception)));
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.resetPassword(event.email);
      emit(AuthPasswordResetSent(email: event.email));
    } catch (e) {
      if (e is AuthException) {
        emit(AuthError(message: e.message, code: e.code));
      } else {
        emit(AuthError(
            message: ExceptionHandler.getUserFriendlyMessage(e as Exception)));
      }
    }
  }

  Future<void> _onPasswordUpdateRequested(
    AuthPasswordUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.updatePassword(event.newPassword);
      emit(AuthPasswordUpdated());
    } catch (e) {
      if (e is AuthException) {
        emit(AuthError(message: e.message, code: e.code));
      } else {
        emit(AuthError(
            message: ExceptionHandler.getUserFriendlyMessage(e as Exception)));
      }
    }
  }

  Future<void> _onBiometricSignInRequested(
    AuthBiometricSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isAvailable = await _authService.isBiometricAvailable();
      if (!isAvailable) {
        emit(const AuthError(
          message: 'Biometric authentication is not available on this device',
          code: 'biometric-not-available',
        ));
        return;
      }

      final isAuthenticated = await _authService.authenticateWithBiometrics();
      if (isAuthenticated) {
        // If biometric authentication is successful,
        // you might want to sign in with stored credentials
        // For now, just emit that biometric is available
        emit(const AuthBiometricAvailable(isAvailable: true));
      } else {
        emit(const AuthError(
          message: 'Biometric authentication failed',
          code: 'biometric-failed',
        ));
      }
    } catch (e) {
      emit(AuthError(
          message: ExceptionHandler.getUserFriendlyMessage(e as Exception)));
    }
  }

  Future<void> _onUserRefreshRequested(
    AuthUserRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userModel = await _authService.getUserDocument(user.uid);
        final roles = await _authService.getUserRoles();

        emit(AuthAuthenticated(
          user: user,
          userModel: userModel,
          roles: roles,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(
          message: ExceptionHandler.getUserFriendlyMessage(e as Exception)));
    }
  }

  // Utility methods
  bool get isAuthenticated => state is AuthAuthenticated;
  bool get isEmployee => _hasRole(UserRole.employee);
  bool get isHR => _hasRole(UserRole.hr);
  bool get isManager => _hasRole(UserRole.manager);
  bool get isAdmin => _hasRole(UserRole.admin);

  bool _hasRole(UserRole role) {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).roles.contains(role);
    }
    return false;
  }

  User? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return null;
  }

  UserModel? get currentUserModel {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).userModel;
    }
    return null;
  }

  List<UserRole> get currentUserRoles {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).roles;
    }
    return [];
  }
}
