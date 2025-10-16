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
      
      final user = AuthUserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@').first,
        email: email,
        token: 'demo-token-${DateTime.now().millisecondsSinceEpoch}',
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
            'username': email,
            'password': password,
          },
        }),
      );

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body) as Map<String, dynamic>;

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
          final userModel = AuthUserModel.fromJson(login!);
          return userModel.copyWith(email: email);
        }
        final error = (login?['error'] ?? 'Login fallido').toString();
        throw ServerException(error);
      }
      throw ServerException('Error de conexión: ${response.statusCode}');
    }
  }
}
