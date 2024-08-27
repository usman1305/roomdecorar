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
          style: TextStyle(color: Colors.white70),
        ),
        backgroundColor: Color.fromRGBO(0, 0, 0, 1),
      ),
      backgroundColor: Colors.black, // Set background color to black
      body: user != null
          ? Column(
        children: [
          const SizedBox(height: 90),
          const CircleAvatar(
            backgroundColor: Colors.white, // Background color for the avatar
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
                '${user.displayName}',
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
                style: const TextStyle(fontSize: 20, color: Colors.white),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Change Password Button for non-admin users
            if (user != null && !isAdmin(user.email)) // Replace with your admin check logic
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 160, // Decrease button width
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      await _sendPasswordResetEmail(user.email);
                    },
                    icon: Icon(Icons.lock),
                    label: Text('Change Password'),
                    backgroundColor: Colors.white70,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
            // Logout Button
            SizedBox(
              width: 120, // Decrease button width
              child: FloatingActionButton.extended(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyLogin())); // Navigate to Login screen
                },
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isAdmin(String? email) {
    // Replace this with your admin logic
    return email == 'musmanejaz007@gmail.com'; // Example admin check
  }

  Future<void> _sendPasswordResetEmail(String? email) async {
    if (email != null && email.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        // Show success message
        print('Password reset email sent to $email');
      } catch (e) {
        // Handle error
        print('Error sending password reset email: $e');
      }
    }
  }
}
