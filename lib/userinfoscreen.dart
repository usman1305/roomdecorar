import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomdecorar/login.dart';

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
        backgroundColor: Color.fromRGBO(96, 218, 94, 1),
      ),
      backgroundColor: Colors.black, // Set background color to black
      body: user != null
          ? Column(
              children: [
                SizedBox(height: 90),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircleAvatar(),
                ),
                SizedBox(height: 90),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${user.displayName}',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${user.email}',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                // You can display more user information here
              ],
            )
          : Center(
              child: Text(
                'User not logged in',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 70),
        child: Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton.extended(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MyLogin())); // Navigate to Login screen
            },
            icon: Icon(Icons.logout),
            label: Text('Logout'),
            backgroundColor: Colors.white70,
            foregroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
        ),
      ),
    );
  }
}
