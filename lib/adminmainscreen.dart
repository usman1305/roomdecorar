import 'package:flutter/material.dart';

class AdminMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Back! 😀',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            ElevatedButton(
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
              onPressed: () {
                // Add functionality for the first button
              },
              child: Text('View 3D Objects'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
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
              onPressed: () {
                // Add functionality for the second button
              },
              child: Text('View Suggestion Set'),
            ),
          ],
        ),
      ),
    );
  }
}
