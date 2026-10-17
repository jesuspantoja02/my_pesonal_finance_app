import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_personal_finance_app/core/config/firebase_env.dart';
import 'package:my_personal_finance_app/core/config/firebase_oauth_defaults.dart';
import 'package:my_personal_finance_app/firebase_options.dart';

abstract final class FirebaseBootstrap {
  static bool _ready = false;

  static bool get isReady => _ready;

  static Future<bool> tryInitialize() async {
    if (_ready) return true;
    if (!DefaultFirebaseOptions.isConfigured) {
      debugPrint('Finanza: Firebase omitido (sin dart-define / flutterfire).');
      return false;
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await GoogleSignIn.instance.initialize(
        clientId: _googlePlatformClientId(),
        serverClientId: _googleWebClientId(),
      );
      _ready = true;
      debugPrint('Finanza: Firebase listo.');
      return true;
    } catch (e, st) {
      debugPrint('Finanza: Firebase init falló: $e\n$st');
      return false;
    }
  }

  static String? _googlePlatformClientId() {
    if (FirebaseEnv.iosClientId.isNotEmpty) {
      return FirebaseEnv.iosClientId;
    }
    if (FirebaseEnv.androidClientId.isNotEmpty) {
      return FirebaseEnv.androidClientId;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return DefaultFirebaseOptions.ios.iosClientId ??
          FirebaseOAuthDefaults.iosClientId;
    }
    return null;
  }

  static String? _googleWebClientId() {
    if (FirebaseEnv.webClientId.isNotEmpty) {
      return FirebaseEnv.webClientId;
    }
    return FirebaseOAuthDefaults.webClientId;
  }
}
