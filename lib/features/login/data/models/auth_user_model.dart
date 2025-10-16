import 'dart:convert';
import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.token,
    required super.role,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    // Decodificar JWT token para extraer user_id y rol
    final token = (json['token'] ?? '').toString();
    String userId = 'backend-user';
    String role = 'student';
    
    if (token.isNotEmpty) {
      try {
        // JWT tiene formato: header.payload.signature
        final parts = token.split('.');
        if (parts.length == 3) {
          // Decodificar payload (base64)
          final payload = parts[1];
          // Agregar padding si es necesario
          final paddedPayload = payload + '=' * (4 - payload.length % 4);
          final decoded = utf8.decode(base64.decode(paddedPayload));
          final payloadJson = jsonDecode(decoded) as Map<String, dynamic>;
          
          userId = (payloadJson['user_id'] ?? 'backend-user').toString();
          role = (payloadJson['rol'] ?? 'student').toString();
          
          // Mapeo temporal: ID 2 siempre es estudiante (hasta que el backend se arregle)
          if (userId == '2') {
            role = 'student';
          }
        }
      } catch (e) {
        print('Error decodificando JWT: $e');
      }
    }
    
    return AuthUserModel(
      id: userId,
      name: 'Usuario', // El backend no devuelve nombre, usamos genérico
      email: '', // El email se añade después con copyWith en el DataSource.
      token: token,
      role: role,
    );
  }

  AuthUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? role,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }

  AuthUser toEntity() => AuthUser(id: id, name: name, email: email, token: token, role: role);
}
