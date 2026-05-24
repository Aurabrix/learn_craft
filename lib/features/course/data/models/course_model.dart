import 'package:learn_craft/features/course/domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.subcategory,
    required super.level,
    required super.totalTokensUsed,
    required super.attachmentUrl,
    required super.createdAt,
    required super.totalLessons,
    required super.totalQuizzes,
    required super.skillsTaught,
    required super.isPublished,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      level: json['level'] ?? 'Beginner',
      totalTokensUsed: json['totalTokensUsed'] ?? 0,
      attachmentUrl: json['attachmentUrl'] ?? '',
      createdAt: _parseDate(json['createdAt']),
      totalLessons: json['totalLessons'] ?? 0,
      totalQuizzes: json['totalQuizzes'] ?? 0,
      skillsTaught: List<String>.from(json['skillsTaught'] ?? []),
      isPublished: json['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'level': level,
      'totalTokensUsed': totalTokensUsed,
      'attachmentUrl': attachmentUrl,
      'createdAt': createdAt.toIso8601String(),
      'totalLessons': totalLessons,
      'totalQuizzes': totalQuizzes,
      'skillsTaught': skillsTaught,
      'isPublished': isPublished,
    };
  }

  static DateTime _parseDate(dynamic value) {
    final now = DateTime.now();
    if (value == null) return now;
    if (value is String) return DateTime.tryParse(value) ?? now;
    return now;
  }
}
