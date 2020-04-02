import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlogin/globaldata.dart';
import 'package:flutterlogin/pages/auth.dart';
import 'package:flutterlogin/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> {
  SharedPreferences prefs;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    Timer(Duration(milliseconds: 1800), () async {
      prefs = await SharedPreferences.getInstance();
      var _isLoggedIn = prefs.getBool("isSignedIn");
      if (_isLoggedIn != true) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(seconds: 1),
            pageBuilder: (_, __, ___) => AuthPage()
          ),
        );
      } else {
        var stream = Firestore.instance
            .collection("user-data")
            .document((await _auth.currentUser()).uid)
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.purple.shade700,
              Colors.deepPurple.shade900,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: "app-logo",
                child: SizedBox(
                  child: Placeholder(
                    color: Colors.white,
                  ),
                  height: 200,
                  width: 200,
                ),
              ),
              SizedBox(height: 40),
              Text(
                "WallCream",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Roboto",
                  fontSize: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
