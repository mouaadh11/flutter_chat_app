import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  //auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print(e);
      return null;
    }
  }
  //register with email and password

  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print(e);
      return null;
    }
  }


  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}