class LessonEntity {
  final String id;
  final String courseId;
  final String lessonId;
  final String topic;
  final String summary;
  final int order;
  final bool isCompleted;
  final bool isCurrentLesson;
  final bool isPublished;

  const LessonEntity({
    required this.id,
    required this.courseId,
    required this.lessonId,
    required this.topic,
    required this.summary,
    required this.order,
    required this.isCompleted,
    required this.isCurrentLesson,
    required this.isPublished,
  });
}
