import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:my_personal_finance_app/core/cloud/firebase_bootstrap.dart';
import 'package:my_personal_finance_app/core/cloud/user_registry.dart';
import 'package:my_personal_finance_app/data/database/app_database.dart';
import 'package:my_personal_finance_app/domain/models/auth_user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService(
    this._db, {
    FlutterSecureStorage? storage,
    UserRegistry? userRegistry,
    firebase_auth.FirebaseAuth? firebaseAuth,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _userRegistry = userRegistry ?? NoOpUserRegistry(),
        _firebaseAuthOverride = firebaseAuth;

  final AppDatabase _db;
  final FlutterSecureStorage _storage;
  final UserRegistry _userRegistry;
  final firebase_auth.FirebaseAuth? _firebaseAuthOverride;

  firebase_auth.FirebaseAuth? get _firebaseAuth {
    if (!_firebaseEnabled) return null;
    return _firebaseAuthOverride ?? firebase_auth.FirebaseAuth.instance;
  }

  firebase_auth.FirebaseAuth get _requireFirebase {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw AuthException('Firebase no está disponible');
    }
    return auth;
  }

  static const _sessionUserIdKey = 'finanza_session_user_id';
  static const _sessionModeKey = 'finanza_session_mode';
  static const _uuid = Uuid();

  bool get _firebaseEnabled => FirebaseBootstrap.isReady;

  Future<bool> hasActiveSession() async {
    final firebase = _firebaseAuth;
    if (firebase != null && firebase.currentUser != null) {
      return true;
    }
    final mode = await _storage.read(key: _sessionModeKey);
    if (mode != 'local') return false;
    final userId = await _storage.read(key: _sessionUserIdKey);
    if (userId == null || userId.isEmpty) return false;
    final row = await (_db.select(_db.users)..where((u) => u.id.equals(userId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<AuthUser?> getCurrentUser() async {
    final firebase = _firebaseAuth;
    if (firebase != null) {
      final fb = firebase.currentUser;
      if (fb != null) {
        return AuthUser(
          id: fb.uid,
          email: fb.email ?? '',
          displayName: fb.displayName ?? fb.email ?? 'Usuario',
          authProvider: _providerFromFirebase(fb),
        );
      }
    }
    final userId = await _storage.read(key: _sessionUserIdKey);
    if (userId == null) return null;
    final row = await (_db.select(_db.users)..where((u) => u.id.equals(userId)))
        .getSingleOrNull();
    if (row == null) return null;
    return AuthUser(
      id: row.id,
      email: row.email,
      displayName: row.displayName,
      authProvider: 'email',
    );
  }

  Future<void> signOut() async {
    final firebase = _firebaseAuth;
    if (firebase != null) {
      await GoogleSignIn.instance.signOut();
      await firebase.signOut();
    }
    await _storage.delete(key: _sessionUserIdKey);
    await _storage.delete(key: _sessionModeKey);
  }

  Future<AuthUser> signInWithGoogle() async {
    if (!_firebaseEnabled) {
      throw AuthException(
        'Google no está disponible. Espera a que Firebase termine de cargar.',
      );
    }
    try {
      firebase_auth.UserCredential result;
      try {
        final account = await GoogleSignIn.instance.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null) {
          throw AuthException('No se obtuvo token de Google');
        }
        result = await _requireFirebase.signInWithCredential(
          firebase_auth.GoogleAuthProvider.credential(idToken: idToken),
        );
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          throw AuthException('Inicio con Google cancelado');
        }
        result = await _signInGoogleWithFirebaseProvider();
      }

      final fb = result.user;
      if (fb == null) {
        throw AuthException('No se pudo iniciar sesión con Google');
      }
      final user = AuthUser(
        id: fb.uid,
        email: fb.email ?? '',
        displayName: fb.displayName ?? fb.email ?? 'Usuario',
        authProvider: 'google',
      );
      await _storage.write(key: _sessionModeKey, value: 'firebase');
      await _recordCloudLogin(user, photoUrl: fb.photoURL);
      return user;
    } on AuthException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e, provider: 'Google'));
    } catch (e) {
      throw AuthException(_mapUnknownSocialError(e, provider: 'Google'));
    }
  }

  Future<firebase_auth.UserCredential> _signInGoogleWithFirebaseProvider() {
    final provider = firebase_auth.GoogleAuthProvider()
      ..addScope('email')
      ..setCustomParameters({'prompt': 'select_account'});
    return _requireFirebase.signInWithProvider(provider);
  }

  Future<AuthUser> signInWithApple() async {
    if (!_firebaseEnabled) {
      throw AuthException(
        'Apple no está disponible. Espera a que Firebase termine de cargar.',
      );
    }
    try {
      firebase_auth.UserCredential result;
      String? appleEmail;
      String? appleName;

      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        result = await _signInAppleNative();
      } else {
        result = await _signInAppleWithFirebaseProvider();
      }

      final fb = result.user;
      if (fb == null) {
        throw AuthException('No se pudo iniciar sesión con Apple');
      }

      appleEmail = fb.email;
      appleName = fb.displayName;
      final displayName = (appleName ?? '').trim().isNotEmpty
          ? appleName!.trim()
          : (appleEmail ?? 'Usuario Apple');

      final user = AuthUser(
        id: fb.uid,
        email: appleEmail ?? '',
        displayName: displayName,
        authProvider: 'apple',
      );
      await _storage.write(key: _sessionModeKey, value: 'firebase');
      await _recordCloudLogin(user, photoUrl: fb.photoURL);
      return user;
    } on AuthException {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthException('Inicio con Apple cancelado');
      }
      throw AuthException('Error con Apple: ${e.message}');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e, provider: 'Apple'));
    } catch (e) {
      throw AuthException(_mapUnknownSocialError(e, provider: 'Apple'));
    }
  }

  Future<firebase_auth.UserCredential> _signInAppleNative() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256Nonce(rawNonce);
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    final idToken = appleCredential.identityToken;
    if (idToken == null) {
      throw AuthException('No se obtuvo token de Apple');
    }
    final result = await _requireFirebase.signInWithCredential(
      firebase_auth.OAuthProvider('apple.com').credential(
        idToken: idToken,
        rawNonce: rawNonce,
      ),
    );
    final given = appleCredential.givenName ?? '';
    final family = appleCredential.familyName ?? '';
    final composedName = '$given $family'.trim();
    if (composedName.isNotEmpty &&
        (result.user?.displayName ?? '').isEmpty) {
      await result.user?.updateDisplayName(composedName);
    }
    return result;
  }

  Future<firebase_auth.UserCredential> _signInAppleWithFirebaseProvider() {
    final provider = firebase_auth.AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    return _requireFirebase.signInWithProvider(provider);
  }

  String _mapAuthError(
    firebase_auth.FirebaseAuthException e, {
    required String provider,
  }) {
    return switch (e.code) {
      'operation-not-allowed' =>
        'Activa $provider en Firebase Console → Authentication → Sign-in method.',
      'network-request-failed' =>
        'Sin conexión. Revisa tu internet e inténtalo de nuevo.',
      'invalid-credential' || 'invalid-id-token' =>
        provider == 'Google'
            ? 'Google no pudo validar la app. Añade el SHA-1 de debug en Firebase → App Android.'
            : 'Apple no está configurado en Firebase (Services ID, Team ID y clave).',
      'user-disabled' => 'Esta cuenta está deshabilitada.',
      'account-exists-with-different-credential' =>
        'Ese correo ya existe con otro método de inicio de sesión.',
      _ => e.message ?? 'No se pudo iniciar con $provider.',
    };
  }

  String _mapUnknownSocialError(Object e, {required String provider}) {
    final text = e.toString();
    if (text.contains('10:') ||
        text.contains('ApiException: 10') ||
        text.contains('DEVELOPER_ERROR')) {
      return 'Error 10 de Google: registra el SHA-1 debug en Firebase Console '
          '(Configuración del proyecto → tu app Android → Agregar huella).';
    }
    if (text.contains('7:') || text.contains('NETWORK')) {
      return 'Sin conexión con $provider. Revisa internet o Play Services.';
    }
    return 'No se pudo iniciar con $provider. $text';
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty) {
      throw AuthException('Ingresa tu correo electrónico');
    }
    if (password.isEmpty) {
      throw AuthException('Ingresa tu contraseña');
    }

    if (_firebaseEnabled) {
      try {
        final result = await _requireFirebase.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        final fb = result.user;
        if (fb == null) throw AuthException('Sesión no válida');
        final user = AuthUser(
          id: fb.uid,
          email: fb.email ?? normalizedEmail,
          displayName: fb.displayName ?? normalizedEmail.split('@').first,
          authProvider: 'email',
        );
        await _storage.write(key: _sessionModeKey, value: 'firebase');
        await _recordCloudLogin(user, photoUrl: fb.photoURL);
        return user;
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          throw AuthException('Correo o contraseña incorrectos');
        }
        throw AuthException(e.message ?? 'No se pudo iniciar sesión');
      }
    }

    final row = await (_db.select(_db.users)
          ..where((u) => u.email.equals(normalizedEmail)))
        .getSingleOrNull();
    if (row == null) {
      throw AuthException('No hay una cuenta con ese correo');
    }

    final hash = _hashPassword(password, row.salt);
    if (hash != row.passwordHash) {
      throw AuthException('Contraseña incorrecta');
    }

    await _storage.write(key: _sessionModeKey, value: 'local');
    await _storage.write(key: _sessionUserIdKey, value: row.id);
    final user = AuthUser(
      id: row.id,
      email: row.email,
      displayName: row.displayName,
      authProvider: 'email',
    );
    await _recordCloudLogin(user);
    return user;
  }

  Future<AuthUser> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final name = displayName.trim();
    final normalizedEmail = _normalizeEmail(email);
    if (name.isEmpty) {
      throw AuthException('Escribe tu nombre');
    }
    if (normalizedEmail.isEmpty || !_isValidEmail(normalizedEmail)) {
      throw AuthException('Correo electrónico no válido');
    }
    if (password.length < 6) {
      throw AuthException('La contraseña debe tener al menos 6 caracteres');
    }

    if (_firebaseEnabled) {
      try {
        final result = await _requireFirebase.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        await result.user?.updateDisplayName(name);
        final fb = result.user;
        if (fb == null) throw AuthException('No se pudo crear la cuenta');
        final user = AuthUser(
          id: fb.uid,
          email: normalizedEmail,
          displayName: name,
          authProvider: 'email',
        );
        await _storage.write(key: _sessionModeKey, value: 'firebase');
        await _recordCloudLogin(user);
        return user;
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw AuthException('Ya existe una cuenta con ese correo');
        }
        throw AuthException(e.message ?? 'No se pudo registrar');
      }
    }

    final existing = await (_db.select(_db.users)
          ..where((u) => u.email.equals(normalizedEmail)))
        .getSingleOrNull();
    if (existing != null) {
      throw AuthException('Ya existe una cuenta con ese correo');
    }

    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.users).insert(
          UsersCompanion.insert(
            id: id,
            email: normalizedEmail,
            displayName: name,
            passwordHash: hash,
            salt: salt,
            createdAt: now,
          ),
        );

    await _storage.write(key: _sessionModeKey, value: 'local');
    await _storage.write(key: _sessionUserIdKey, value: id);
    final user = AuthUser(
      id: id,
      email: normalizedEmail,
      displayName: name,
      authProvider: 'email',
    );
    await _recordCloudLogin(user);
    return user;
  }

  Future<void> clearAllUsers() async {
    await _db.delete(_db.users).go();
    await signOut();
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  String _providerFromFirebase(firebase_auth.User fb) {
    final provider = fb.providerData.isNotEmpty
        ? fb.providerData.first.providerId
        : 'password';
    if (provider.contains('google')) return 'google';
    if (provider.contains('apple')) return 'apple';
    return 'email';
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256Nonce(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  String _platformLabel() {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => 'other',
    };
  }

  Future<void> _recordCloudLogin(
    AuthUser user, {
    String? photoUrl,
  }) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final platform = _platformLabel();

      final snapshot = CloudUserSnapshot(
        uid: user.id,
        email: user.email,
        displayName: user.displayName,
        authProvider: user.authProvider,
        lastLoginAt: DateTime.now().toUtc(),
        photoUrl: photoUrl,
        platform: platform,
        appVersion: packageInfo.version,
      );

      // Plan Spark: escribe perfil + login_events directo en Firestore
      // (el panel admin lee esto sin Cloud Functions).
      await _userRegistry.recordLogin(snapshot);
    } catch (_) {
      // La app sigue funcionando offline si la nube falla.
    }
  }
}
