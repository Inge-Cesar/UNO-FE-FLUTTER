import '../../../../core/session/session_manager.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  UserProfileModel? getCurrentUser();
  Future<void> saveUser(UserProfileModel user);
  Future<void> clearUser();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SessionManager sessionManager;

  ProfileLocalDataSourceImpl({required this.sessionManager});

  @override
  UserProfileModel? getCurrentUser() {
    final session = sessionManager.currentSession.value;
    if (session == null) return null;
    
    return UserProfileModel(
      id: 'user_${session.userName}',
      name: session.userName,
      email: session.email,
      lastLogin: DateTime.now(),
    );
  }

  @override
  Future<void> saveUser(UserProfileModel user) async {
    // En una implementación real, guardarías en SharedPreferences o similar
    // Por ahora solo actualizamos la sesión
    sessionManager.setSession(Session(
      token: sessionManager.currentSession.value?.token ?? '',
      userName: user.name,
      email: user.email,
    ));
  }

  @override
  Future<void> clearUser() async {
    sessionManager.clear();
  }
}
