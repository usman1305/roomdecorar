import 'package:flutter/material.dart';
import 'package:roomdecorar/customerbottomnavigation.dart';
import 'login.dart';
import 'package:roomdecorar/register.dart';
import 'package:roomdecorar/homescreen.dart';
import 'package:roomdecorar/forgetpassword.dart';
import 'package:roomdecorar/userinfoscreen.dart';
import 'package:roomdecorar/adminmainscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set the initial route to login
      routes: {
        '/': (context) => const MyLogin(),
        'register': (context) => const MyRegister(),
        'homescreen': (context) => const HomeScreen(),
        'forgetpassword': (context) => const ForgotPasswordScreen(),
        'bottomnaigation': (context) => BottomNaigationbarz(),
        'userinfoscreen': (context) => UserInfoScreen(),
        'adminmain': (context) => AdminMainScreen()
      },
    );
  }
}
