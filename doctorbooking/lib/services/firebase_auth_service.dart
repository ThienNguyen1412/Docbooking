import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  FirebaseAuthService._private();
  static final FirebaseAuthService instance = FirebaseAuthService._private();

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  fb.User? get currentUser => _auth.currentUser;

  Future<fb.User?> signInWithGoogle() async {
    try {
      // 🔹 Bước 1: Khởi tạo plugin (nếu chưa làm ở app khởi động)
      await _googleSignIn.initialize();

      // 🔹 Bước 2: Gọi đăng nhập (hiển thị popup)
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate(scopeHint: ['email', 'profile']);

      // 🔹 Bước 3: Lấy idToken (chỉ có idToken, không có accessToken)
      final googleAuth = googleUser.authentication;

      // 🔹 Bước 4: Tạo credential cho Firebase
      final credential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken hiện không còn, để null
      );

      // 🔹 Bước 5: Đăng nhập Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } finally {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
  }

  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  Map<String, dynamic>? getUserProfile() {
    final u = _auth.currentUser;
    if (u == null) return null;
    return {
      'uid': u.uid,
      'email': u.email,
      'displayName': u.displayName,
      'photoURL': u.photoURL,
      'emailVerified': u.emailVerified,
    };
  }
}
