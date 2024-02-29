import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  String? _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildResetPasswordButton(),
                const SizedBox(height: 20),
                _buildBackToLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/logo.png',
      width: 300,
      height: 300,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      style: const TextStyle(color: Colors.white70),
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[850],
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black38,
          ),
        ),
        hintText: "Email",
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.endsWith('@gmail.com')) {
          return 'Please enter a valid Gmail address';
        }
        return null;
      },
      onSaved: (value) {
        _email = value;
      },
    );
  }

  Widget _buildResetPasswordButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          // If the form is valid, save the fields and proceed
          _formKey.currentState!.save();
          try {
            // Send password reset email to the user
            await FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);
            // Show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password reset email sent to $_email'),
              ),
            );
          } catch (e) {
            // Show an error message if sending email fails
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send password reset email: $e'),
              ),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white70,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: 60,
          vertical: 15,
        ),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 3,
      ),
      child: const Text(
        'Reset Password',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context); // Navigate back to the login screen
      },
      child: const Text(
        'Back to Login',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
