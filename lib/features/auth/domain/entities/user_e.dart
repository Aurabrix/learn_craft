class UserEntity {
  final String id;
  final String name;
  final String email;
  final String profileImage;
  final String deviceToken;
  final String deviceType;
  final String appVersion;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLoginAt;
  final List<String> enrolledCourses;
  final int totalAiCredits;
  final int usedAiCredits;
  final String preferredLanguage;
  final int xpPoints;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.deviceToken,
    required this.deviceType,
    required this.appVersion,
    required this.isPremium,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
    required this.enrolledCourses,
    required this.totalAiCredits,
    required this.usedAiCredits,
    required this.preferredLanguage,
    required this.xpPoints,
  });
}
