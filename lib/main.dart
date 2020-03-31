import 'package:flutter/material.dart';
import 'package:flutterlogin/pages/auth.dart';
import 'package:flutterlogin/pages/home.dart';
import 'package:flutterlogin/pages/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      debugShowCheckedModeBanner: false,
      home: Splash(), // MyHomePage(),
    );
  }
}
