import 'package:fling/InitializingPage.dart';
import 'package:fling/UserData.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';

void main() => runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    )
);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context){
    return new SplashScreen(
        seconds: 8,
        navigateAfterSeconds: new InitializingPage(),
        title: new Text('Fling',style: TextStyle(color: Colors.blue[600],fontSize: 50),),
        image: new Image.network('https://media.istockphoto.com/vectors/royal-lion-king-design-inspiration-vector-id1173067389?k=6&m=1173067389&s=612x612&w=0&h=MC-44Nu1b9FOjENV7iA3l-NxCkA2PVQtHCT2yZ0feKw='),
        loadingText: Text('fling welcomes you',style: TextStyle(color: Colors.blue[600],fontSize: 20),),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        loaderColor: Colors.blue[800]
    );
  }

  Future alreadyLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      RegisteredData.uid = preferences.getString('UID');
      InitializingPage.alreadyLoggedIn = preferences.getBool('LOGGEDIN');
    });
  }
}



