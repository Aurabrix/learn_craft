import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Seeds sample course + lessons + quizzes data into Firestore.
class CourseSeedService {
  final FirebaseFirestore _firestore;

  CourseSeedService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Writes the sample course document, lessons subcollection, and quizzes.
  /// Returns `true` on success.
  Future<bool> seedSampleCourse() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    const courseId = 'course_001';
    final courseRef = _firestore.collection('courses').doc(courseId);

    final courseData = {
      'id': courseId,
      'uid': uid,
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
        'summary': 'Intro to Flutter',
        'content':
            '## What is Flutter?\n\nFlutter is Google\'s open-source UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.\n\n### Key Features\n- **Hot Reload** — see changes instantly\n- **Expressive UI** — rich set of widgets\n- **Native Performance** — compiled to ARM code',
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
        'summary': 'Learn Dart fundamentals',
        'content':
            '## Dart Language Basics\n\nDart is the language behind Flutter.\n\n### Variables\n```dart\nvar name = \'Flutter\';\nint count = 42;\nbool isActive = true;\n```\n\n### Control Flow\n- `if / else`\n- `for` loops\n- `switch` statements',
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
        'summary': 'Build UI with widgets',
        'content':
            '## Widgets & Layouts\n\nEverything in Flutter is a widget.\n\n### Common Widgets\n- `Text` — display text\n- `Container` — box model\n- `Row` / `Column` — flex layout\n- `Stack` — overlay widgets',
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
        'summary': 'Manage app state',
        'content':
            '## State Management\n\nFlutter offers multiple ways to manage state.\n\n### Approaches\n- `setState` — simple local state\n- `BLoC / Cubit` — scalable pattern\n- `Provider` — lightweight DI',
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
        'summary': 'Screen navigation',
        'content':
            '## Navigation & Routing\n\nFlutter uses GoRouter for declarative routing.\n\n### Basics\n```dart\ncontext.push(\'/details\');\ncontext.pop();\n```\n\n### Route Guards\nRedirect unauthenticated users to login.',
        'order': 5,
        'isCompleted': false,
        'isCurrentLesson': false,
        'isPublished': false,
      },
    ];

    // Quiz for lesson_001
    final quizzes = <String, Map<String, dynamic>>{
      'lesson_001': {
        'id': 'quiz_001',
        'courseId': courseId,
        'lessonId': 'lesson_001',
        'title': 'What is Flutter? — Quiz',
        'totalQuestions': 5,
        'questions': [
          {
            'id': 'q_001',
            'questionText': 'What programming language does Flutter use?',
            'options': ['Java', 'Dart', 'Kotlin', 'Swift'],
            'correctOptionIndex': 1,
            'explanation':
                'Flutter uses Dart as its programming language, developed by Google.',
            'xpPoints': 10,
            'difficulty': 'Beginner',
          },
          {
            'id': 'q_002',
            'questionText': 'Which company developed Flutter?',
            'options': ['Apple', 'Microsoft', 'Google', 'Meta'],
            'correctOptionIndex': 2,
            'explanation':
                'Flutter is an open-source UI toolkit created by Google.',
            'xpPoints': 10,
            'difficulty': 'Easy',
          },
          {
            'id': 'q_003',
            'questionText': 'What is a Widget in Flutter?',
            'options': [
              'A database table',
              'A UI building block',
              'A network request',
              'A test framework',
            ],
            'correctOptionIndex': 1,
            'explanation':
                'In Flutter, everything is a widget — the basic building block of the UI.',
            'xpPoints': 15,
            'difficulty': 'Beginner',
          },
          {
            'id': 'q_004',
            'questionText': 'Flutter apps can run on which platforms?',
            'options': [
              'Only Android',
              'Only iOS',
              'Android and iOS only',
              'Android, iOS, Web, Desktop',
            ],
            'correctOptionIndex': 3,
            'explanation':
                'Flutter supports Android, iOS, Web, Windows, macOS, and Linux.',
            'xpPoints': 15,
            'difficulty': 'Easy',
          },
          {
            'id': 'q_005',
            'questionText': 'What is hot reload in Flutter?',
            'options': [
              'Restarting the device',
              'Instantly reflecting code changes without losing state',
              'Clearing the cache',
              'Updating the SDK',
            ],
            'correctOptionIndex': 1,
            'explanation':
                'Hot reload injects updated source code into the running Dart VM without restarting the app.',
            'xpPoints': 20,
            'difficulty': 'Beginner',
          },
        ],
      },
    };

    // Use a batch write — atomic, all-or-nothing
    final batch = _firestore.batch();

    batch.set(courseRef, courseData);

    for (final lesson in lessons) {
      final lessonId = lesson['lessonId'] as String;
      final lessonRef = courseRef.collection('lessons').doc(lessonId);
      batch.set(lessonRef, lesson);

      // Add quiz if one exists for this lesson
      if (quizzes.containsKey(lessonId)) {
        final quizData = quizzes[lessonId]!;
        final quizRef =
            lessonRef.collection('quizzes').doc(quizData['id'] as String);
        batch.set(quizRef, quizData);
      }
    }

    await batch.commit();
    return true;
  }
}
