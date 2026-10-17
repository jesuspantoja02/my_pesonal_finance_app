/// Valores de Firebase. Tras `flutterfire configure`, copia aquí o usa:
/// `flutter run --dart-define-from-file=config/firebase_defines.json`
abstract final class FirebaseEnv {
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const storageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const iosBundleId =
      String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');
  static const androidClientId =
      String.fromEnvironment('GOOGLE_ANDROID_CLIENT_ID');
  static const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
  static const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  static bool get isConfigured =>
      apiKey.isNotEmpty && appId.isNotEmpty && projectId.isNotEmpty;
}
