import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetCurrentUserUseCase {
  final ProfileRepository repository;
  const GetCurrentUserUseCase(this.repository);

  Future<UserProfile> call() {
    return repository.getCurrentUser();
  }
}
