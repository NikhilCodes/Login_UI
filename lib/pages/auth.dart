import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterlogin/custom_shapes.dart';
import 'package:flutterlogin/pages/home.dart';
import 'package:flutterlogin/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String loginText = "";
  String modeChangeText = "";
  String mode = ""; // sign_in or sign_up
  double heightFraction = 0;
  SharedPreferences prefs;
  List<Widget> inputSections = [];
  var loginFromSubmitButtonIcon;
  FirebaseAuth _auth = FirebaseAuth.instance;

  static TextEditingController _userNameController = TextEditingController(),
      _emailIdController = TextEditingController(),
      _phoneNumberController = TextEditingController(),
      _passwordController = TextEditingController(),
      _confirmPasswordController = TextEditingController();

  final signUpInputSections = [
    Row(
      children: <Widget>[
        Icon(Icons.person_pin, color: Colors.blue.shade300),
        SizedBox(width: 10),
        Flexible(
          child: TextField(
            controller: _userNameController,
            decoration: textFieldDecorUser,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    ),
    Row(
      children: <Widget>[
        Icon(Icons.email, color: Colors.yellow.shade300),
        SizedBox(width: 10),
        Flexible(
          child: TextField(
            controller: _emailIdController,
            decoration: textFieldDecorEmail,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    ),
    Row(
      children: <Widget>[
        Icon(Icons.phone, color: Colors.redAccent),
        SizedBox(width: 10),
        Flexible(
          child: TextField(
            controller: _phoneNumberController,
            decoration: textFieldDecorPhone,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    ),
    Row(
      children: <Widget>[
        Icon(Icons.lock_outline, color: Colors.greenAccent),
        SizedBox(width: 10),
        Flexible(
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: textFieldDecorPassword,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    ),
    Row(
      children: <Widget>[
        Icon(Icons.lock, color: Colors.lightGreenAccent),
        SizedBox(width: 10),
        Flexible(
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: textFieldDecorConfirmPassword,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    ),
  ];

  final signInInputSections = [
    Row(
      children: <Widget>[
        Icon(Icons.person_pin, color: Colors.blue.shade300),
        SizedBox(width: 10),
        Flexible(
          child: TextField(
            controller: _userNameController,
            decoration: textFieldDecorUser,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    ),
    Row(
      children: <Widget>[
        Icon(Icons.lock, color: Colors.lightGreenAccent),
        SizedBox(width: 10),
        Flexible(
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: textFieldDecorPassword,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    ),
  ];

  void switchToSignUp() {
    setState(() {
      modeChangeText = "Already a user?";
      loginText = "Sign Up";
      inputSections = signUpInputSections;
    });
    mode = "sign_up";
  }

  void switchToSignIn() {
    setState(() {
      modeChangeText = "Create an Account";
      loginText = "Sign In";
      inputSections = signInInputSections;
    });
    mode = "sign_in";
  }

  Future startUpJobs(BuildContext context) async {
    setState(() {
      loginFromSubmitButtonIcon = Icon(Icons.arrow_forward);
    });
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("hasAccount") == null) {
      switchToSignUp();
    } else {
      var _loginUID = prefs.getString("UID");
      if (_loginUID == null) {
        switchToSignIn();
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
    }
  }

  void onSignIn() async {
    String emailId;
    await Firestore.instance
        .collection("relations")
        .document("user->email")
        .get()
        .then((value) {
      emailId = value[_userNameController.text];
    });
    final result = await _auth.signInWithEmailAndPassword(
        email: emailId, password: _passwordController.text);

    if (result == null) {
      print("Invalid Credentials!");
      return null;
    }
    prefs.setBool("hasAccount", true);
    prefs.setString("UID", result.user.uid);

    var stream = Firestore.instance
        .collection("user-data")
        .document(result.user.uid)
        .snapshots();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(stream: stream)),
    );
  }

  void onSignUp() async {
    // _auth.createUserWithEmailAndPassword(email: null, password: null)
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => startUpJobs(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Color.fromRGBO(20, 20, 60, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: CustomPaint(
                painter: TopSection(),
                child: Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    loginText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            SafeArea(
              //duration: Duration(milliseconds: 50),
              //alignment: Alignment.centerLeft,
              //width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height * heightFraction,
              child: Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.15),
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 25, top: 10, bottom: 10, right: 30),
                      margin: EdgeInsets.only(top: 15, bottom: 15),
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                      child: Column(
                        children: inputSections,
                      ),
                    ),
                  ),
                  Positioned(
                    right: MediaQuery.of(context).size.width * 0.075,
                    child: FloatingActionButton(
                      backgroundColor: Colors.purple.shade600,
                      child: loginFromSubmitButtonIcon,
                      onPressed: () {
                        if (mode == "sign_in") {
                          setState(() {
                            loginFromSubmitButtonIcon =
                                CircularProgressIndicator();
                          });
                          onSignIn();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: CustomPaint(
                painter: BottomSection(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: ButtonTheme(
                        buttonColor: Colors.transparent,
                        child: RaisedButton(
                          elevation: 0,
                          highlightElevation: 0,
                          onPressed: () {
                            if (mode == "sign_up")
                              switchToSignIn();
                            else
                              switchToSignUp();
                          },
                          child: Text(
                            modeChangeText,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(bottom: 20),
                      child: ButtonTheme(
                        height: 50,
                        minWidth: 220,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        buttonColor: Colors.black12,
                        child: RaisedButton(
                          elevation: 0,
                          highlightElevation: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Log In with ",
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: Image.asset("images/googleLogo.png"),
                              ),
                            ],
                          ),
                          onPressed: () {
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
