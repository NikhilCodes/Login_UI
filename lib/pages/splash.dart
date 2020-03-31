import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterlogin/pages/auth.dart';
import 'package:flutterlogin/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> {
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    Timer(Duration(milliseconds: 1800), () async {
      prefs = await SharedPreferences.getInstance();
      var _loginUID = prefs.getString("UID");
      if (_loginUID == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthPage()),
        );
      } else {
        var stream = Firestore.instance
            .collection("user-data")
            .document(_loginUID)
            .snapshots();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(stream: stream)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade600,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("images/logo.png"),
            SizedBox(height: 10),
            Text(
              "NikhilCodes",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w300,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
