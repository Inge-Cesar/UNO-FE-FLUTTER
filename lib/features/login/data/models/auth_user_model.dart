import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.token,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: 'backend-user', // ID genérico.
      name: 'Usuario', // Nombre genérico.
      email: '', // El email se añade después con copyWith.
      token: (json['token'] ?? '').toString(),
    );
  }

  AuthUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }

  AuthUser toEntity() => AuthUser(id: id, name: name, email: email, token: token);
}
