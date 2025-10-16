import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime? lastLogin;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.lastLogin,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatar: json['avatar']?.toString(),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.tryParse(json['lastLogin'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar': avatar,
        'lastLogin': lastLogin?.toIso8601String(),
      };

  UserProfile toEntity() => UserProfile(
        id: id,
        name: name,
        email: email,
        avatar: avatar,
        lastLogin: lastLogin,
      );
}
