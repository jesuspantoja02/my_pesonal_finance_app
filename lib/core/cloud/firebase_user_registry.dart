import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_personal_finance_app/core/cloud/user_registry.dart';
import 'package:my_personal_finance_app/core/config/cloud_config.dart';

class FirebaseUserRegistry implements UserRegistry {
  FirebaseUserRegistry(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<bool> get isAvailable async => true;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(CloudConfig.usersCollection);

  @override
  Future<void> recordLogin(CloudUserSnapshot snapshot) async {
    final ref = _collection.doc(snapshot.uid);
    final existing = await ref.get();
    final data = <String, dynamic>{
      'email': snapshot.email,
      'displayName': snapshot.displayName,
      'authProvider': snapshot.authProvider,
      'lastLoginAt': FieldValue.serverTimestamp(),
      'loginCount': FieldValue.increment(1),
      if (snapshot.photoUrl != null) 'photoUrl': snapshot.photoUrl,
      if (snapshot.platform != null) 'platform': snapshot.platform,
      if (snapshot.appVersion != null) 'appVersion': snapshot.appVersion,
    };
    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await ref.set(data, SetOptions(merge: true));

    // Historial por ingreso (panel admin en Spark lee esto sin Cloud Functions).
    await ref.collection('login_events').add({
      'at': FieldValue.serverTimestamp(),
      'platform': snapshot.platform ?? 'unknown',
      'appVersion': snapshot.appVersion ?? '',
      'authProvider': snapshot.authProvider,
    });
  }

  @override
  Future<List<CloudUserSnapshot>> listUsersForAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesión');
    }
    final token = await user.getIdTokenResult();
    final isAdmin = token.claims?['admin'] == true ||
        CloudConfig.isAdminEmail(user.email);
    if (!isAdmin) {
      throw StateError('No tienes permisos de administrador');
    }

    final snap = await _collection
        .orderBy('lastLoginAt', descending: true)
        .limit(200)
        .get();

    return snap.docs.map(_fromDoc).toList();
  }

  CloudUserSnapshot _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final lastLogin = data['lastLoginAt'];
    DateTime lastLoginAt;
    if (lastLogin is Timestamp) {
      lastLoginAt = lastLogin.toDate();
    } else {
      lastLoginAt = DateTime.fromMillisecondsSinceEpoch(0);
    }
    return CloudUserSnapshot(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      authProvider: data['authProvider'] as String? ?? 'unknown',
      lastLoginAt: lastLoginAt,
      photoUrl: data['photoUrl'] as String?,
      platform: data['platform'] as String?,
      appVersion: data['appVersion'] as String?,
    );
  }
}
