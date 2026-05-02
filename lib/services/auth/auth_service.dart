import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/services/chat/chat_notification.dart';

class AuthService {
  //auth & firestore instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user exists, if not create with default values
      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'uid': userCredential.user!.uid,
          'username': email.split('@').first,
          'avatarUrl': '',
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
  //register with email and password

  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      // add the user to the users collection in firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'uid': userCredential.user!.uid,
        'username': username,
        'avatarUrl': '',
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  //sign out
  Future<void> signOut() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await ChatNotification().removeCurrentTokenForUser(currentUser.uid);
    }
    await _auth.signOut();
  }

  //update user profile
  Future<void> updateUserProfile({String? username, String? avatarUrl}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not authenticated");
    }

    Map<String, dynamic> updateData = {};
    if (username != null) updateData['username'] = username;
    if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .update(updateData);
  }

  //get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final doc = await _firestore.collection('users').doc(currentUser.uid).get();
    return doc.data();
  }

  //get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
