import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Model for unified social login user data across Google & Apple
class SocialAuthUser {
  final String provider; // 'google' or 'apple'
  final String idToken;
  final String? accessToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String? rawNonce;

  const SocialAuthUser({
    required this.provider,
    required this.idToken,
    this.accessToken,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.rawNonce,
  });

  Map<String, dynamic> toMap() => {
        'provider': provider,
        'idToken': idToken,
        'accessToken': accessToken,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
      };
}

/// Result wrapper for social auth actions
sealed class SocialAuthResult {
  const SocialAuthResult();
}

class SocialAuthSuccess extends SocialAuthResult {
  final SocialAuthUser user;
  final UserCredential? firebaseCredential;
  const SocialAuthSuccess({required this.user, this.firebaseCredential});
}

class SocialAuthCanceled extends SocialAuthResult {
  const SocialAuthCanceled();
}

class SocialAuthFailure extends SocialAuthResult {
  final String message;
  final dynamic error;
  const SocialAuthFailure({required this.message, this.error});
}

/// Comprehensive, production-ready Social Authentication Service
class SocialAuthService {
  final String? googleWebClientId;
  final String? googleIosClientId;
  final String? googleAndroidClientId;
  final String? appleServiceId;
  final String? appleRedirectUri;
  final bool linkWithFirebase;

  bool _googleReady = false;

  SocialAuthService({
    this.googleWebClientId,
    this.googleIosClientId,
    this.googleAndroidClientId,
    this.appleServiceId,
    this.appleRedirectUri,
    this.linkWithFirebase = true,
  });

  /// Ensures GoogleSignIn v7 instance is initialized with platform client IDs
  Future<void> _ensureGoogleInitialized() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: googleWebClientId,
      clientId: Platform.isIOS ? googleIosClientId : googleAndroidClientId,
    );
    _googleReady = true;
  }

  // ─────────────────────────────────────────────────────────
  // ─── GOOGLE SIGN-IN ───────────────────────────────────────
  // ─────────────────────────────────────────────────────────

  Future<SocialAuthResult> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final auth = account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        return const SocialAuthFailure(
          message: 'لم يتم العثور على رمز idToken من حساب جوجل',
        );
      }

      UserCredential? firebaseCred;
      if (linkWithFirebase) {
        try {
          final credential = GoogleAuthProvider.credential(
            idToken: idToken,
            accessToken: auth.accessToken,
          );
          firebaseCred = await FirebaseAuth.instance
              .signInWithCredential(credential)
              .timeout(const Duration(seconds: 10));
        } catch (e) {
          developer.log('Firebase Google Sign-In warning: $e', name: 'SocialAuthService');
        }
      }

      final fbUser = FirebaseAuth.instance.currentUser;
      final user = SocialAuthUser(
        provider: 'google',
        idToken: idToken,
        accessToken: auth.accessToken,
        email: fbUser?.email ?? account.email,
        displayName: fbUser?.displayName ?? account.displayName,
        photoUrl: fbUser?.photoURL ?? account.photoUrl,
        phoneNumber: fbUser?.phoneNumber,
      );

      return SocialAuthSuccess(user: user, firebaseCredential: firebaseCred);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return const SocialAuthCanceled();
      }
      return SocialAuthFailure(
        message: 'فشل تسجيل الدخول بواسطة جوجل: ${e.description ?? e.code.name}',
        error: e,
      );
    } catch (e) {
      if (_isUserCanceled(e)) {
        return const SocialAuthCanceled();
      }
      return SocialAuthFailure(message: 'حدث خطأ أثناء تسجيل الدخول بجوجل: $e', error: e);
    }
  }

  // ─────────────────────────────────────────────────────────
  // ─── APPLE SIGN-IN ────────────────────────────────────────
  // ─────────────────────────────────────────────────────────

  Future<SocialAuthResult> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      final appleCred = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
        webAuthenticationOptions: Platform.isIOS
            ? null
            : (appleServiceId != null && appleRedirectUri != null
                ? WebAuthenticationOptions(
                    clientId: appleServiceId!,
                    redirectUri: Uri.parse(appleRedirectUri!),
                  )
                : null),
      );

      final identityToken = appleCred.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        return const SocialAuthFailure(
          message: 'لم يتم استلام رمز identityToken من خدمة أبل',
        );
      }

      UserCredential? firebaseCred;
      if (linkWithFirebase) {
        try {
          final credential = OAuthProvider('apple.com').credential(
            idToken: identityToken,
            rawNonce: rawNonce,
          );
          firebaseCred = await FirebaseAuth.instance
              .signInWithCredential(credential)
              .timeout(const Duration(seconds: 10));
        } catch (e) {
          developer.log('Firebase Apple Sign-In warning: $e', name: 'SocialAuthService');
        }
      }

      final fbUser = FirebaseAuth.instance.currentUser;
      final fullName = [
        appleCred.givenName ?? '',
        appleCred.familyName ?? '',
      ].where((part) => part.isNotEmpty).join(' ');

      final user = SocialAuthUser(
        provider: 'apple',
        idToken: identityToken,
        email: fbUser?.email ?? appleCred.email,
        displayName: fullName.isNotEmpty
            ? fullName
            : (fbUser?.displayName ?? 'Apple User'),
        photoUrl: fbUser?.photoURL,
        phoneNumber: fbUser?.phoneNumber,
        rawNonce: rawNonce,
      );

      return SocialAuthSuccess(user: user, firebaseCredential: firebaseCred);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const SocialAuthCanceled();
      }
      return SocialAuthFailure(
        message: 'فشل تسجيل الدخول بواسطة أبل: ${e.message}',
        error: e,
      );
    } catch (e) {
      if (_isUserCanceled(e)) {
        return const SocialAuthCanceled();
      }
      return SocialAuthFailure(message: 'حدث خطأ أثناء تسجيل الدخول بأبل: $e', error: e);
    }
  }

  // ─────────────────────────────────────────────────────────
  // ─── LOGOUT ───────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────
  // ─── HELPERS ──────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────

  bool _isUserCanceled(Object error) {
    if (error is GoogleSignInException) {
      return error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted;
    }
    final text = error.toString().toLowerCase();
    return text.contains('canceled') ||
        text.contains('cancelled') ||
        text.contains('sign_in_canceled');
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
