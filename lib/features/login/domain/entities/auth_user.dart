class AuthUser {
  final String id;
  final String name;
  final String email;
  final String token;
  final String role;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.role,
  });
}


