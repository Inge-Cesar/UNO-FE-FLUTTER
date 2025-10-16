import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// Features: login, profile
import '../network/http_client_provider.dart';
import '../theme/theme_manager.dart'; 
import '../session/session_manager.dart';
import '../../features/login/data/datasources/auth_remote_data_source.dart';
import '../../features/login/data/repositories/auth_repository_impl.dart';
import '../../features/login/domain/repositories/auth_repository.dart';
import '../../features/login/domain/usecases/login_user.dart';
import '../../features/login/presentation/bloc/login_bloc.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_current_user.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<http.Client>(() => provideHttpClient());
  sl.registerLazySingleton<SessionManager>(() => SessionManager());
  sl.registerLazySingleton<ThemeManager>(() => ThemeManager());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sessionManager: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton<LoginUserUseCase>(
    () => LoginUserUseCase(sl()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl()),
  );

  // Presentation
  sl.registerFactory<LoginBloc>(() => LoginBloc(loginUser: sl()));
}