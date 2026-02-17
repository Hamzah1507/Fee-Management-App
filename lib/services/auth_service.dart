import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ REGISTER
  Future<User?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 🔹 1. Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw 'User creation failed';

      // ✅ Optional but recommended
      await user.sendEmailVerification();

      print("✅ USER CREATED: ${user.uid}");

      // 🔹 2. Save user data to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ DATA SAVED TO FIRESTORE");

      return user;
    } on FirebaseAuthException catch (e) {
      print("❌ AUTH ERROR: ${e.message}");
      throw e.message ?? 'Registration failed';
    } catch (e) {
      print("❌ UNKNOWN ERROR: $e");
      rethrow;
    }
  }

  // ✅ LOGIN
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("✅ LOGIN SUCCESS");
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print("❌ LOGIN ERROR: ${e.message}");
      throw e.message ?? 'Login failed';
    }
  }

  // ✅ LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    print("✅ LOGOUT SUCCESS");
  }

  // ✅ CURRENT USER
  User? get currentUser => _auth.currentUser;
}
