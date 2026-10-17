class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.authProvider = 'email',
  });

  final String id;
  final String email;
  final String displayName;

  /// `email`, `google` o `apple` (Firebase); local usa `email`.
  final String authProvider;

  String get firstName {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? displayName : parts.first;
  }
}
