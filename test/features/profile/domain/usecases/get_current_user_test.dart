import 'package:flutter_test/flutter_test.dart';
import 'package:jueves/features/profile/domain/entities/user_profile.dart';
import 'package:jueves/features/profile/domain/repositories/profile_repository.dart';
import 'package:jueves/features/profile/domain/usecases/get_current_user.dart';

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile> getCurrentUser() async {
    return const UserProfile(
      id: 'user_123',
      name: 'Usuario Test',
      email: 'test@example.com',
    );
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    // Mock implementation
  }
}

void main() {
  test('GetCurrentUserUseCase retorna perfil del repositorio', () async {
    final repo = _FakeProfileRepository();
    final usecase = GetCurrentUserUseCase(repo);

    final result = await usecase();

    expect(result, isA<UserProfile>());
    expect(result.id, 'user_123');
    expect(result.name, 'Usuario Test');
    expect(result.email, 'test@example.com');
  });
}
