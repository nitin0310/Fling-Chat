import 'package:fling/Dashboard.dart';
import 'package:fling/SignUp_Page.dart';
import 'package:fling/UserData.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitializingPage extends StatefulWidget {

  static bool alreadyLoggedIn=false;

  @override
  _InitializingPageState createState() => _InitializingPageState();
}

class _InitializingPageState extends State<InitializingPage> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(child: CircularProgressIndicator(),);
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return InitializingPage.alreadyLoggedIn?Dashboard():SignUp_Page();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(child: CircularProgressIndicator());
      },
    );
  }

}
