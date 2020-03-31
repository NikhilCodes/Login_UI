import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterlogin/custom_shapes.dart';
import 'package:flutterlogin/globaldata.dart';
import 'package:flutterlogin/pages/home.dart';
import 'package:flutterlogin/styles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  String loginText = "";
  String modeChangeText = "";
  String mode = ""; // sign_in or sign_up
  double googleSignInButtonOpacity = 0.0;
  double topHeightFraction = 0.2,
      bottomHeightFraction = 0.2,
      formHeightFraction = 0.4;
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
        Icon(Icons.person, color: Colors.blue.shade300),
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
        Icon(Icons.person, color: Colors.blue.shade300),
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
      topHeightFraction = 0.22;
      formHeightFraction = 0.50;
      bottomHeightFraction = 0.22;
      googleSignInButtonOpacity = 0.0;
      inputSections = signUpInputSections;
    });

    mode = "sign_up";
  }

  void switchToSignIn() {
    setState(() {
      modeChangeText = "Create an Account";
      loginText = "Sign In";
      topHeightFraction = 0.30;
      formHeightFraction = 0.25;
      bottomHeightFraction = 0.30;
      googleSignInButtonOpacity = 1.0;
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
      if (prefs.getBool("isSignedIn") != true ||
          (await _auth.currentUser()).isEmailVerified == false) {
        switchToSignIn();
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
      emailId = value[_userNameController.text.toLowerCase()];
    });
    final _result = await _auth.signInWithEmailAndPassword(
        email: emailId, password: _passwordController.text);

    if (_result == null) {
      print("Invalid Credentials!");
      return null;
    }

    if (!_result.user.isEmailVerified) {
      setState(() {
        loginFromSubmitButtonIcon = Icon(Icons.arrow_forward);
      });
      showAlertDialog(context, "Alert", "Verify your email, then Sign In!");
      return null;
    }
    prefs.setBool("hasAccount", true);
    prefs.setBool("isSignedIn", true);

    var stream = Firestore.instance
        .collection("user-data")
        .document(_result.user.uid)
        .snapshots();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(stream: stream)),
    );
  }

  void onSignUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      print("Password and Confirm Password donot match!");
      return null;
    }

    AuthResult _result;
    try {
      _result = await _auth.createUserWithEmailAndPassword(
          email: _emailIdController.text, password: _passwordController.text);
      if (_result == null) {
        print("Invalid Credentials!");
        return null;
      }
    } catch (signUpError) {
      if (signUpError is PlatformException) {
        if (signUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          /// `foo@bar.com` has already been registered.
          print("Email Already in use!");
          return null;
        }
      }
    }

    UserUpdateInfo userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = _userNameController.text;
    await _result.user.updateProfile(userUpdateInfo);

    _result.user.sendEmailVerification(); // Sending Verification Mail

    await Firestore.instance
        .collection("relations")
        .document("user->email")
        .setData(
            {_userNameController.text.toLowerCase(): _emailIdController.text},
            merge: true);

    await Firestore.instance
        .collection("user-data")
        .document(_result.user.uid)
        .setData({
      "username": _userNameController.text,
      "MP": (1000 + Random().nextInt(100000 - 1000)).toString(),
      "your_skill": skillSet[Random().nextInt(skillSet.length)],
      "phonenumber": (_phoneNumberController.text.startsWith("+"))
          ? _phoneNumberController.text
          : "+91" + _phoneNumberController.text,
    });

    Fluttertoast.showToast(
      msg: "Verify email and Sign In!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );

    prefs.setBool("hasAccount", true);
    prefs.setBool("isSignedIn", true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => startUpJobs(context));
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Color.fromRGBO(20, 20, 60, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedContainer(
              height: MediaQuery.of(context).size.height * topHeightFraction,
              curve: Curves.easeOut,
              duration: Duration(milliseconds: 200),
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
            AnimatedContainer(
              duration: Duration(milliseconds: 100),
              //width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * formHeightFraction,
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
                      margin: EdgeInsets.only(top: 13, bottom: 0),
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        physics: NeverScrollableScrollPhysics(),
                        //mainAxisAlignment: MainAxisAlignment.center,
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
                        setState(() {
                          loginFromSubmitButtonIcon =
                              CircularProgressIndicator();
                        });
                        if (mode == "sign_in") {
                          onSignIn();
                        } else {
                          onSignUp();
                        }
//                        _phoneNumberController.text = "";
//                        _emailIdController.text = "";
//                        _userNameController.text = "";
//                        _passwordController.text = "";
//                        _confirmPasswordController.text = "";
                      },
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 150),
              curve: Curves.easeOut,
              height: MediaQuery.of(context).size.height * bottomHeightFraction,
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
                      child: AnimatedOpacity(
                        opacity: googleSignInButtonOpacity,
                        duration: Duration(milliseconds: 200),
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
                                  "Sign In with ",
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
                            onPressed: () async {
                              // Disabling Button when in SignUp
                              if (mode == "sign_up") {
                                return null;
                              }

                              GoogleSignIn googleSignIn = GoogleSignIn();
                              GoogleSignInAccount account =
                                  await googleSignIn.signIn();

                              if (account == null) {
                                return null;
                              }

                              final GoogleSignInAuthentication googleAuth =
                                  await account.authentication;

                              // get the credentials to (access / id token)
                              // to sign in via Firebase Authentication
                              final AuthCredential credential =
                                  GoogleAuthProvider.getCredential(
                                      accessToken: googleAuth.accessToken,
                                      idToken: googleAuth.idToken);

                              FirebaseUser user =
                                  (await _auth.signInWithCredential(credential))
                                      .user;

                              if (!user.isEmailVerified) {
                                setState(() {
                                  loginFromSubmitButtonIcon =
                                      Icon(Icons.arrow_forward);
                                });
                                showAlertDialog(context, "Alert",
                                    "Verify your email, then Sign In!");
                                return null;
                              }

                              // Now we store some data in prefs and then Navigate.
                              prefs.setBool("hasAccount", true);
                              prefs.setBool("isSignedIn", true);

                              var stream = Firestore.instance
                                  .collection("user-data")
                                  .document(user.uid)
                                  .snapshots();

                              print("VERIFIED...");
                              print(user.displayName);
                              print(user.isEmailVerified);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MyHomePage(stream: stream)),
                              );
                            },
                          ),
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
