import 'package:learn_craft/features/course/domain/entities/lesson_entity.dart';

class LessonModel extends LessonEntity {
  const LessonModel({
    required super.id,
    required super.courseId,
    required super.lessonId,
    required super.topic,
    required super.summary,
    required super.order,
    required super.isCompleted,
    required super.isCurrentLesson,
    required super.isPublished,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      lessonId: json['lessonId'] ?? '',
      topic: json['topic'] ?? '',
      summary: json['summary'] ?? '',
      order: json['order'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isCurrentLesson: json['isCurrentLesson'] ?? false,
      isPublished: json['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'lessonId': lessonId,
      'topic': topic,
      'summary': summary,
      'order': order,
      'isCompleted': isCompleted,
      'isCurrentLesson': isCurrentLesson,
      'isPublished': isPublished,
    };
  }
}
