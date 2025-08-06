import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

import '../models/user_model.dart';
import '../utils/exceptions.dart';

/// Authentication service handling Firebase Auth operations
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login timestamp
      if (credential.user != null) {
        await _updateLastLogin(credential.user!.uid);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    }
  }

  /// Sign in with phone number and OTP
  Future<UserCredential> signInWithPhoneNumber({
    required String phoneNumber,
    required String smsCode,
    required String verificationId,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Update last login timestamp
      if (userCredential.user != null) {
        await _updateLastLogin(userCredential.user!.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    }
  }

  /// Send phone verification code
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    }
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) throw const AuthException('User not authenticated');

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    }
  }

  /// Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = currentUser;
      if (user == null) throw const AuthException('User not authenticated');

      await user.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) throw const AuthException('User not authenticated');

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    }
  }

  /// Reauthenticate user
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = currentUser;
      if (user == null) throw const AuthException('User not authenticated');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw const AuthException('User not authenticated');

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    }
  }

  /// Get user document from Firestore
  Future<UserModel?> getUserDocument(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user document: $e');
    }
  }

  /// Update user document in Firestore
  Future<void> updateUserDocument(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Error updating user document: $e');
    }
  }

  /// Get user roles from custom claims
  Future<List<UserRole>> getUserRoles() async {
    try {
      final user = currentUser;
      if (user == null) throw const AuthException('User not authenticated');

      final idTokenResult = await user.getIdTokenResult();
      final claims = idTokenResult.claims;

      if (claims != null && claims.containsKey('roles')) {
        final rolesList = List<String>.from(claims['roles'] as List);
        return rolesList
            .map((role) => UserRole.values.firstWhere(
                  (e) => e.toString().split('.').last == role,
                  orElse: () => UserRole.employee,
                ))
            .toList();
      }

      return [UserRole.employee]; // Default role
    } catch (e) {
      throw Exception('Error fetching user roles: $e');
    }
  }

  /// Check if user has specific role
  Future<bool> hasRole(UserRole role) async {
    try {
      final roles = await getUserRoles();
      return roles.contains(role);
    } catch (e) {
      return false;
    }
  }

  /// Biometric authentication
  Future<bool> authenticateWithBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return false;

      final result = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the HR app',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      return result;
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Validate Sri Lankan phone number format
  bool isValidSriLankanPhoneNumber(String phoneNumber) {
    // Remove any spaces or special characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Check for valid Sri Lankan phone number formats
    final patterns = [
      RegExp(r'^\+94[0-9]{9}$'), // +94XXXXXXXXX
      RegExp(r'^94[0-9]{9}$'), // 94XXXXXXXXX
      RegExp(r'^0[0-9]{9}$'), // 0XXXXXXXXX
      RegExp(r'^[0-9]{10}$'), // XXXXXXXXXX
    ];

    return patterns.any((pattern) => pattern.hasMatch(cleanNumber));
  }

  /// Format Sri Lankan phone number
  String formatSriLankanPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanNumber.startsWith('+94')) {
      return cleanNumber;
    } else if (cleanNumber.startsWith('94')) {
      return '+$cleanNumber';
    } else if (cleanNumber.startsWith('0')) {
      return '+94${cleanNumber.substring(1)}';
    } else if (cleanNumber.length == 9) {
      return '+94$cleanNumber';
    }

    return phoneNumber; // Return original if no pattern matches
  }

  /// Private helper methods

  /// Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final userDoc = UserModel(
      id: user.uid,
      email: user.email!,
      phoneNumber: user.phoneNumber,
      roles: const [UserRole.employee], // Default role
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userDoc.toJson());
  }

  /// Update last login timestamp
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Check account lockout status
  Future<bool> isAccountLocked(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      final userData = querySnapshot.docs.first.data();
      final lockoutUntil = userData['lockoutUntil'] as Timestamp?;

      if (lockoutUntil == null) return false;

      return DateTime.now().isBefore(lockoutUntil.toDate());
    } catch (e) {
      return false;
    }
  }

  /// Record failed login attempt
  Future<void> recordFailedLoginAttempt(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final docRef = querySnapshot.docs.first.reference;
      final userData = querySnapshot.docs.first.data();

      final failedAttempts = (userData['failedLoginAttempts'] as int? ?? 0) + 1;
      const maxAttempts = 5;

      final updateData = <String, dynamic>{
        'failedLoginAttempts': failedAttempts,
        'lastFailedLoginAt': FieldValue.serverTimestamp(),
      };

      // Lock account if max attempts reached
      if (failedAttempts >= maxAttempts) {
        updateData['lockoutUntil'] = Timestamp.fromDate(
          DateTime.now().add(const Duration(minutes: 30)),
        );
      }

      await docRef.update(updateData);
    } catch (e) {
      // Log error but don't throw to avoid blocking login flow
      print('Error recording failed login attempt: $e');
    }
  }

  /// Reset failed login attempts on successful login
  Future<void> resetFailedLoginAttempts(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'failedLoginAttempts': FieldValue.delete(),
        'lastFailedLoginAt': FieldValue.delete(),
        'lockoutUntil': FieldValue.delete(),
      });
    } catch (e) {
      // Log error but don't throw
      print('Error resetting failed login attempts: $e');
    }
  }
}
