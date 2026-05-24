import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_craft/features/course/data/models/course_model.dart';
import 'package:learn_craft/features/course/data/models/lesson_model.dart';

import 'course_remote_data_source.dart';

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final FirebaseFirestore _firestore;

  CourseRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<CourseModel>> getCourses(String uid) async {
    final snapshot = await _firestore
        .collection('courses')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CourseModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<CourseModel?> getCourseById(String courseId) async {
    final doc = await _firestore.collection('courses').doc(courseId).get();

    if (!doc.exists || doc.data() == null) return null;
    return CourseModel.fromJson(doc.data()!);
  }

  @override
  Future<List<LessonModel>> getLessons(String courseId) async {
    final snapshot = await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => LessonModel.fromJson(doc.data()))
        .toList();
  }
}
