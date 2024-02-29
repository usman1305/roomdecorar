import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  static Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the email is verified
      if (!userCredential.user!.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email address to login.',
        );
      }
    } catch (e) {
      throw e;
    }
  }
}
