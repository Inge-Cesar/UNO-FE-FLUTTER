class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime? lastLogin;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.lastLogin,
  });
}
