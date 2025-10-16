import 'package:flutter/foundation.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginUserUseCase {
  final AuthRepository repository;
  const LoginUserUseCase(this.repository);

  Future<AuthUser> call({required String email, required String password}) {
    if (kDebugMode) {
      print('DEBUG USECASE: Iniciando caso de uso login');
    }
    return repository.login(email: email, password: password);
  }
}
