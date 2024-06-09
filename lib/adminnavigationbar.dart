import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:roomdecorar/userinfoscreen.dart';
import 'package:roomdecorar/adminmainscreen.dart';
import 'package:roomdecorar/AddObjectScreen.dart';
import 'package:roomdecorar/view3dObjects.dart';

class AdminBottomNaigationbarz extends StatefulWidget {
  @override
  State createState() {
    return _FluidNavBarDemoState();
  }
}

class _FluidNavBarDemoState extends State {
  Widget? _child;

  @override
  void initState() {
    _child = AdminMainScreen();
    super.initState();
  }

  @override
  Widget build(context) {
    // Build a simple container that switches content based of off the selected navigation item
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF75B7E1),
        extendBody: true,
        body: _child,
        bottomNavigationBar: FluidNavBar(
          icons: [
            FluidNavBarIcon(
                icon: Icons.home_rounded, extras: {"label": "home"}),
            FluidNavBarIcon(
                icon: Icons.folder_open, extras: {"label": "draftsetfolder"}),
            FluidNavBarIcon(
                icon: Icons.search, extras: {"label": "searchitem"}),
            FluidNavBarIcon(
                icon: Icons.account_circle_outlined,
                extras: {"label": "userinfo"}),
          ],
          onChange: _handleNavigationChange,
          style: const FluidNavBarStyle(
            barBackgroundColor: Color.fromRGBO(35, 35, 35, 1),
            iconBackgroundColor: Color.fromRGBO(96, 218, 94, 1),
            iconSelectedForegroundColor: Color.fromARGB(255, 0, 0, 0),
            iconUnselectedForegroundColor: Color.fromARGB(183, 255, 255, 255),
          ),
          scaleFactor: 1.5,
          itemBuilder: (icon, item) => Semantics(
            label: icon.extras!["label"],
            child: item,
          ),
        ),
      ),
    );
  }

  void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          _child = AdminMainScreen();
          break;
        case 1:
          break;
        case 2:
          break;
        case 3:
          _child = UserInfoScreen();
          break;
      }
      _child = AnimatedSwitcher(
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        duration: Duration(milliseconds: 500),
        child: _child,
      );
    });
  }
}
