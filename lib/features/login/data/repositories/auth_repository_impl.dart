import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthUser> login({required String email, required String password}) async {
    _log('Iniciando login en repositorio');
    try {
      final model = await remoteDataSource.login(email: email, password: password);
      _log('Modelo obtenido del datasource: ${model.name}');
      final entity = model.toEntity();
      _log('Entidad convertida: ${entity.name}');
      return entity;
    } catch (e) {
      _log('Error en repositorio: $e');
      rethrow;
    }
  }

  void _log(String message) {
    final String prefix = 'DEBUG REPOSITORY: ';
    if (kIsWeb) {
      print('$prefix (Web) $message');
    } else {
      debugPrint('$prefix (Non-Web) $message');
    }
  }
}
