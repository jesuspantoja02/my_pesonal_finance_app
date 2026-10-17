/// Metadatos que SÍ pueden vivir en la nube (nunca movimientos ni saldos).
class CloudUserSnapshot {
  const CloudUserSnapshot({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.authProvider,
    required this.lastLoginAt,
    this.photoUrl,
    this.platform,
    this.appVersion,
  });

  final String uid;
  final String email;
  final String displayName;
  final String authProvider;
  final DateTime lastLoginAt;
  final String? photoUrl;
  final String? platform;
  final String? appVersion;
}

/// Sincroniza registro / último ingreso. Implementación Firebase en fase 2.
abstract class UserRegistry {
  Future<void> recordLogin(CloudUserSnapshot snapshot);

  Future<List<CloudUserSnapshot>> listUsersForAdmin();

  Future<bool> get isAvailable;
}

/// Mientras Firebase no esté configurado, no envía nada a la red.
class NoOpUserRegistry implements UserRegistry {
  @override
  Future<bool> get isAvailable async => false;

  @override
  Future<void> recordLogin(CloudUserSnapshot snapshot) async {}

  @override
  Future<List<CloudUserSnapshot>> listUsersForAdmin() async => [];
}
