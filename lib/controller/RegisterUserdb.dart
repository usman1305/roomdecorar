import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class RegisterUserdb {
  static Future<void> registerUser(
      String name, String email, String password, File image) async {
    try {
      // Create a user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set the display name for the user
      await userCredential.user!.updateDisplayName(name);

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Check if the email is verified
      if (!userCredential.user!.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email address.',
        );
      }

      // Registration successful and email is verified, save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid) // Use user's UID as document ID
          .set({
        'name': name,
        'email': email,
        'image_url': '', // Add image URL if needed
      });
    } catch (e) {
      // Registration failed, handle the error
      throw e;
    }
  }
}
