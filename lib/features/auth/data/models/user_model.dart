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
    required super.updatedAt,
    required super.lastLoginAt,
    required super.enrolledCourses,
    required super.totalAiCredits,
    required super.usedAiCredits,
    required super.preferredLanguage,
    required super.xpPoints,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      deviceType: json['deviceType'] ?? '',
      appVersion: json['appVersion'] ?? '',
      isPremium: json['isPremium'] ?? false,
      createdAt: _parseDate(json['createdAt'], now),
      updatedAt: _parseDate(json['updatedAt'], now),
      lastLoginAt: _parseDate(json['lastLoginAt'], now),
      enrolledCourses: List<String>.from(json['enrolledCourses'] ?? []),
      totalAiCredits: json['totalAiCredits'] ?? 0,
      usedAiCredits: json['usedAiCredits'] ?? 0,
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      xpPoints: json['xpPoints'] ?? 0,
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
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'enrolledCourses': enrolledCourses,
      'totalAiCredits': totalAiCredits,
      'usedAiCredits': usedAiCredits,
      'preferredLanguage': preferredLanguage,
      'xpPoints': xpPoints,
    };
  }

  static DateTime _parseDate(dynamic value, DateTime fallback) {
    if (value == null) return fallback;
    if (value is String) return DateTime.tryParse(value) ?? fallback;
    return fallback;
  }
}
