
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/entities/auth_user.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/session/session_manager.dart';

// Events
abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  LoginSubmitted({required this.email, required this.password});
}

// States
abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final AuthUser user;
  const LoginSuccess(this.user);
}

class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUserUseCase loginUser;
  LoginBloc({required this.loginUser}) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginLoading());
    try {
      final user = await loginUser(email: event.email, password: event.password);
      sl<SessionManager>().setSession(Session(userId: user.id, token: user.token, userName: user.name, email: user.email, userRole: user.role));
      emit(LoginSuccess(user));
    } on ServerException catch (e) {
      emit(LoginError(e.message));
    } catch (e) {
      emit(const LoginError('Ocurrió un error inesperado. Revisa tu conexión.'));
    }
  }
}
