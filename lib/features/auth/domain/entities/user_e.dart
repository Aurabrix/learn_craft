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
  });
}
