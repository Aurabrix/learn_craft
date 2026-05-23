import 'package:learn_craft/features/auth/domain/entities/user_e.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.profileImage,
    required super.deviceToken,
    required super.deviceType,
    required super.appVersion,
    required super.isPremium,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      deviceType: json['deviceType'] ?? '',
      appVersion: json['appVersion'] ?? '',
      isPremium: json['isPremium'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'deviceToken': deviceToken,
      'deviceType': deviceType,
      'appVersion': appVersion,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
