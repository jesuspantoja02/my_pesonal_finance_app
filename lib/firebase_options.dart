import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:my_personal_finance_app/core/config/firebase_env.dart';

/// Generado/actualizado con `flutterfire configure`.
/// Opcional: `--dart-define-from-file=config/firebase_defines.json` para OAuth.
class DefaultFirebaseOptions {
  static bool get isConfigured =>
      FirebaseEnv.isConfigured || android.projectId.isNotEmpty;

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw UnsupportedError(
        'Firebase no configurado. Ejecuta: flutterfire configure '
        'o usa --dart-define-from-file=config/firebase_defines.json',
      );
    }
    if (kIsWeb) {
      return FirebaseEnv.isConfigured ? _webFromEnv : web;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        FirebaseEnv.isConfigured ? _androidFromEnv : android,
      TargetPlatform.iOS || TargetPlatform.macOS =>
        FirebaseEnv.isConfigured ? _iosFromEnv : ios,
      _ => throw UnsupportedError('Plataforma no soportada'),
    };
  }

  static FirebaseOptions get _androidFromEnv => FirebaseOptions(
        apiKey: FirebaseEnv.apiKey,
        appId: FirebaseEnv.appId,
        messagingSenderId: FirebaseEnv.messagingSenderId,
        projectId: FirebaseEnv.projectId,
        storageBucket: FirebaseEnv.storageBucket,
      );

  static FirebaseOptions get _iosFromEnv => FirebaseOptions(
        apiKey: FirebaseEnv.apiKey,
        appId: FirebaseEnv.appId,
        messagingSenderId: FirebaseEnv.messagingSenderId,
        projectId: FirebaseEnv.projectId,
        storageBucket: FirebaseEnv.storageBucket,
        iosBundleId: FirebaseEnv.iosBundleId,
      );

  static FirebaseOptions get _webFromEnv => FirebaseOptions(
        apiKey: FirebaseEnv.apiKey,
        appId: FirebaseEnv.appId,
        messagingSenderId: FirebaseEnv.messagingSenderId,
        projectId: FirebaseEnv.projectId,
        authDomain: '${FirebaseEnv.projectId}.firebaseapp.com',
        storageBucket: FirebaseEnv.storageBucket,
      );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBhBaQV8IBJ-L-CbPY69FYhKHU7ecgRba0',
    appId: '1:531680073782:android:2d4b41c6a3b3ff1b972097',
    messagingSenderId: '531680073782',
    projectId: 'my-personal-finance-app-1ff47',
    storageBucket: 'my-personal-finance-app-1ff47.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAVIzscGHX9zIwySc6qzsp17WpHdRMXPE0',
    appId: '1:531680073782:ios:0e55507e3a96b6bc972097',
    messagingSenderId: '531680073782',
    projectId: 'my-personal-finance-app-1ff47',
    storageBucket: 'my-personal-finance-app-1ff47.firebasestorage.app',
    iosClientId:
        '531680073782-2joitqrqb45fkv3po4qsb665fcoophu7.apps.googleusercontent.com',
    iosBundleId: 'com.example.myPersonalFinanceApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDO4--RVlAY5hLFGQBYUTKogrkpZt4uMtc',
    appId: '1:531680073782:web:9cc37d1789352fc7972097',
    messagingSenderId: '531680073782',
    projectId: 'my-personal-finance-app-1ff47',
    authDomain: 'my-personal-finance-app-1ff47.firebaseapp.com',
    storageBucket: 'my-personal-finance-app-1ff47.firebasestorage.app',
    measurementId: 'G-D7FG0HFDWM',
  );
}
