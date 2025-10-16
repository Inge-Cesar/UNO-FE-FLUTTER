import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getCurrentUser();
  Future<void> updateProfile(UserProfile profile);
}
