import 'package:cloud_firestore/cloud_firestore.dart';

/// Seeds sample course + lessons data into Firestore.
class CourseSeedService {
  final FirebaseFirestore _firestore;

  CourseSeedService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Writes the sample course document and its lessons subcollection.
  /// Returns `true` on success.
  Future<bool> seedSampleCourse() async {
    const courseId = 'course_001';
    final courseRef = _firestore.collection('courses').doc(courseId);

    final courseData = {
      'id': courseId,
      'title': 'Flutter Basics',
      'description': 'Learn the fundamentals of Flutter development',
      'category': 'Mobile Development',
      'subcategory': 'Cross-Platform',
      'level': 'Beginner',
      'totalTokensUsed': 45000,
      'attachmentUrl':
          'https://example.com/attachments/flutter-basics-course.pdf',
      'createdAt': '2025-01-15T10:00:00.000Z',
      'totalLessons': 12,
      'totalQuizzes': 3,
      'skillsTaught': ['Dart', 'Widgets', 'State Management', 'UI Design'],
      'isPublished': true,
    };

    final lessons = [
      {
        'id': 'lesson_001',
        'courseId': courseId,
        'lessonId': 'lesson_001',
        'topic': 'What is Flutter?',
        'summary': 'Introduction to Flutter framework',
        'order': 1,
        'isCompleted': true,
        'isCurrentLesson': false,
        'isPublished': true,
      },
      {
        'id': 'lesson_002',
        'courseId': courseId,
        'lessonId': 'lesson_002',
        'topic': 'Dart Language Basics',
        'summary': 'Variables, types, and control flow in Dart',
        'order': 2,
        'isCompleted': true,
        'isCurrentLesson': false,
        'isPublished': true,
      },
      {
        'id': 'lesson_003',
        'courseId': courseId,
        'lessonId': 'lesson_003',
        'topic': 'Widgets & Layouts',
        'summary': 'Understanding the widget tree and layout system',
        'order': 3,
        'isCompleted': false,
        'isCurrentLesson': true,
        'isPublished': true,
      },
      {
        'id': 'lesson_004',
        'courseId': courseId,
        'lessonId': 'lesson_004',
        'topic': 'State Management',
        'summary': 'Managing state with setState and BLoC',
        'order': 4,
        'isCompleted': false,
        'isCurrentLesson': false,
        'isPublished': true,
      },
      {
        'id': 'lesson_005',
        'courseId': courseId,
        'lessonId': 'lesson_005',
        'topic': 'Navigation & Routing',
        'summary': 'GoRouter and screen transitions',
        'order': 5,
        'isCompleted': false,
        'isCurrentLesson': false,
        'isPublished': false,
      },
    ];

    // Use a batch write — atomic, all-or-nothing
    final batch = _firestore.batch();

    batch.set(courseRef, courseData);

    for (final lesson in lessons) {
      final lessonRef =
          courseRef.collection('lessons').doc(lesson['lessonId'] as String);
      batch.set(lessonRef, lesson);
    }

    await batch.commit();
    return true;
  }
}
