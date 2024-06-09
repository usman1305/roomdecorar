import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomdecorar/login.dart';

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Information',
          style: const TextStyle(color: Colors.white70),
        ),
        backgroundColor: Color.fromRGBO(0, 0, 0, 1),
      ),
      backgroundColor: Colors.black, // Set background color to black
      body: user != null
          ? Column(
              children: [
                const SizedBox(height: 90),
                const CircleAvatar(
                  backgroundColor:
                      Colors.white, // Background color for the avatar
                  radius: 75,
                  child: Icon(
                    Icons.account_circle, // Icon for the avatar
                    size: 150,
                    color: Colors.grey, // Color of the icon
                  ),
                ),
                const SizedBox(height: 90),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ' ${user.displayName}',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
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
                'ADMIN',
                style: TextStyle(
                    fontSize: 33,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
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
