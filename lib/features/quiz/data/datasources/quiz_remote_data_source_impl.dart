import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_craft/features/quiz/data/datasources/quiz_remote_data_source.dart';
import 'package:learn_craft/features/quiz/data/models/quiz_model.dart';

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final FirebaseFirestore _firestore;

  QuizRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<QuizModel?> getQuiz({
    required String courseId,
    required String lessonId,
  }) async {
    final snap = await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .collection('quizzes')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return QuizModel.fromJson(snap.docs.first.data());
  }
}
