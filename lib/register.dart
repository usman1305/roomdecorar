import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomdecorar/controller/RegisterUserdb.dart';
import 'dart:io';

class MyRegister extends StatefulWidget {
  const MyRegister({Key? key}) : super(key: key);

  @override
  _MyRegisterState createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  File? _image = null;
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _password;

  Future getImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 25, top: 3),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!👋',
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                  Text(
                    'Let\'s create your account!',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 5), // Adding some space between texts
                ],
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.12),
                child: Form(
                  key: _formKey, // Assign the form key to the form
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 35, right: 35),
                        child: Column(
                          children: [
                            // Image upload section
                            GestureDetector(
                              onTap: getImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    _image == null ? null : FileImage(_image!),
                                child: _image == null
                                    ? const Icon(
                                        Icons.account_circle_rounded,
                                        size: 100,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ) // Icon image when no image is selected
                                    : null, // No child when an image is selected
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              style: const TextStyle(color: Colors.white70),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[850], // Background color
                                enabledBorder: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                hintText: "Name",
                                hintStyle: const TextStyle(
                                  color: Colors.white38,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _name = value;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              style: const TextStyle(color: Colors.white70),
                              keyboardType: TextInputType
                                  .emailAddress, // Set the keyboard type to email address
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[850],
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(),
                                ), // Background color
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                hintText:
                                    "Email", // Changed hintText to "Email"
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
                            ),
                            const SizedBox(
                              height: 15,
                            ),

                            TextFormField(
                              style: const TextStyle(color: Colors.white70),
                              obscureText:
                                  true, // Set obscureText to true to hide the entered text
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[850], // Background color
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
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
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters long';
                                }
                                if (!value.contains(RegExp(r'[A-Z]'))) {
                                  return 'Password must contain at least one uppercase letter';
                                }
                                if (!value.contains(RegExp(r'[a-z]'))) {
                                  return 'Password must contain at least one lowercase letter';
                                }
                                if (!value.contains(RegExp(r'[0-9]'))) {
                                  return 'Password must contain at least one digit';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _password = value;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),

                            const SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Verify Email have been sent.'),
                                  ),
                                );
                                if (_formKey.currentState!.validate()) {
                                  // If the form is valid, create user with email and password
                                  _formKey.currentState!.save();
                                  try {
                                    await RegisterUserdb.registerUser(
                                        _name!, _email!, _password!);
                                  } catch (e) {
                                    // Registration failed the error (e.g., show error message)
                                    print(e);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.white70, // Background color
                                foregroundColor: Colors.black, // Text color
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 93,
                                    vertical: 0), // Button padding
                                textStyle:
                                    const TextStyle(fontSize: 14), // Text style
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      50), // Button border radius
                                ),
                                elevation: 3, // Button elevation
                              ),
                              child: const Text(
                                'Create your account',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.white70, // Background color
                                      foregroundColor:
                                          Colors.black, // Text color
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 5,
                                      ), // Button padding
                                      textStyle: const TextStyle(
                                          fontSize: 16), // Text style
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            50), // Button border radius
                                      ),
                                      elevation: 3, // Button elevation
                                    ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
