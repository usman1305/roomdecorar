import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:roomdecorar/controller/LoginAuth.dart';
import 'package:roomdecorar/adminmainscreen.dart';
import 'package:roomdecorar/bottomnavigation.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final _formKey = GlobalKey<FormState>(); // Key for the form

  String? _email;
  String? _password;

  // Constants for the predefined email and password
  static const String _constantEmail = 'admin';
  static const String _constantPassword = 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey, // Assign the form key to the form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildLoginButton(),
                const SizedBox(height: 20),
                _buildForgotPasswordLink(),
                const SizedBox(height: 90),
                _buildCreateAccountLink(),
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
        // if (!value.endsWith('@gmail.com')) {
        //   return 'Please enter a valid Gmail address';
        // }
        return null;
      },
      onSaved: (value) {
        _email = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      style: const TextStyle(color: Colors.white70),
      obscureText: true,
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
        hintText: "Password",
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null; // Remove other validation conditions
      },
      onSaved: (value) {
        _password = value;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          if (_email == _constantEmail && _password == _constantPassword) {
            // Redirect to another screen if the entered email and password match
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminMainScreen()),
            );
          } else {
            // Proceed with regular authentication if the entered details do not match
            try {
              await Auth.signIn(_email!, _password!);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BottomNaigationbarz()));
            } catch (e) {
              // Show an error dialog if login fails
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Login Error'),
                    content: Text(e.toString()),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
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
        'Login',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, 'forgetpassword');
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildCreateAccountLink() {
    return SizedBox(
      height: 40, // Adjust the height as needed
      child: RichText(
        text: TextSpan(
          text: 'Don\'t have an account? ',
          style: const TextStyle(color: Colors.white, fontSize: 18),
          children: [
            TextSpan(
              text: 'Create account',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(context, 'register');
                },
            ),
          ],
        ),
      ),
    );
  }
}
