class CourseEntity {
  final String id;
  final String uid;
  final String title;
  final String description;
  final String category;
  final String subcategory;
  final String level;
  final int totalTokensUsed;
  final String attachmentUrl;
  final DateTime createdAt;
  final int totalLessons;
  final int totalQuizzes;
  final List<String> skillsTaught;
  final bool isPublished;

  const CourseEntity({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.level,
    required this.totalTokensUsed,
    required this.attachmentUrl,
    required this.createdAt,
    required this.totalLessons,
    required this.totalQuizzes,
    required this.skillsTaught,
    required this.isPublished,
  });
}
