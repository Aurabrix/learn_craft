import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:learn_craft/features/auth/data/models/user_model.dart';

import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _messaging = messaging ?? FirebaseMessaging.instance;

  @override
  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String avatarUrl,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    await user.updateDisplayName(name);

    String fcmToken = '';
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        await _messaging.requestPermission();
      }
      fcmToken = await _messaging.getToken() ?? '';
    } catch (_) {
      // APNS token not yet available (simulator or permissions not granted)
    }

    final userModel = UserModel(
      id: user.uid,
      name: name,

      email: email,
      profileImage: avatarUrl,
      deviceToken: fcmToken,
      deviceType: Platform.isIOS ? 'ios' : 'android',
      appVersion: '',
      isPremium: false,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final query = await _firestore
        .collection('users')
        .where('name', isEqualTo: username)
        .limit(1)
        .get();

    return query.docs.isEmpty;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
