import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/profile_local_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<UserProfile> getCurrentUser() async {
    try {
      final model = localDataSource.getCurrentUser();
      if (model == null) {
        throw const ServerFailure('No hay usuario autenticado');
      }
      return model.toEntity();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw const ServerFailure('Error al obtener perfil');
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        avatar: profile.avatar,
        lastLogin: profile.lastLogin,
      );
      await localDataSource.saveUser(model);
    } catch (e) {
      throw const ServerFailure('Error al actualizar perfil');
    }
  }
}
