/// Identidad en la nube (Firebase). Los movimientos y cuentas NO se suben.
abstract final class CloudConfig {
  /// Correo admin extra vía `--dart-define=ADMIN_EMAIL=tu@gmail.com`.
  static const _adminEmailFromEnv = String.fromEnvironment('ADMIN_EMAIL');

  /// Correos admin del panel web (también en firestore.rules).
  static Set<String> get adminEmails {
    final emails = <String>{
      'jesuspantojabarrial.02@gmail.com',
    };
    final extra = _adminEmailFromEnv.trim().toLowerCase();
    if (extra.isNotEmpty) emails.add(extra);
    return emails;
  }

  static bool isAdminEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return adminEmails.contains(email.trim().toLowerCase());
  }

  /// Colección Firestore: solo perfil y último ingreso (sin transacciones).
  static const usersCollection = 'app_users';
}
