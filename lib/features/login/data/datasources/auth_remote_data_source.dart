import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/config/app_config.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthUserModel> login({required String email, required String password}) async {
    if (AppConfig.useMockMode) {
      // MODO SIMULADO: Devuelve un usuario de prueba.
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Simulación de roles por email específico
      final isAdmin = email == 'admin@test.com' || email.contains('admin');
      final isStudent = email == 'student@test.com' || email.contains('student');

      final user = AuthUserModel(
        id: isAdmin ? 'user_1' : 'user_2',
        name: isAdmin ? 'Admin User' : 'Student User',
        email: email,
        token: 'demo-token-${DateTime.now().millisecondsSinceEpoch}',
        role: isAdmin ? 'admin' : 'student',
      );
      return user;
    } else {
      // MODO REAL: Petición GraphQL al backend.
      const String loginMutation = r'''
        mutation Login($username: String!, $password: String!) {
          login(username: $username, password: $password) {
            success
            error
            token
          }
        }
      ''';

      final uri = Uri.parse(AppConfig.graphqlUrl);
      final response = await client.post(
        uri,
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'query': loginMutation,
          'variables': {
            'username': email, // El backend espera username, no email
            'password': password,
          },
        }),
      );

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body) as Map<String, dynamic>;
        print('DEBUG BACKEND RESPONSE: $raw'); // Debug del backend

        // Manejo de errores estándar de GraphQL.
        if (raw.containsKey('errors')) {
          final errors = raw['errors'] as List;
          final errorMessage = errors.first['message'] ?? 'Error en la petición GraphQL';
          throw ServerException(errorMessage);
        }

        final data = raw['data'] as Map<String, dynamic>?;
        final login = data?['login'] as Map<String, dynamic>?;
        final success = login?['success'] == true;

        if (success) {
          // El email no viene en la respuesta, así que lo añadimos manualmente.
          final userModel = AuthUserModel.fromJson(login!).copyWith(email: email);
          print('DEBUG USER MODEL: ${userModel.toEntity()}'); // Debug del usuario
          return userModel;
        }
        final error = (login?['error'] ?? 'Login fallido').toString();
        throw ServerException(error);
      }
      throw ServerException('Error de conexión: ${response.statusCode}');
    }
  }
}
