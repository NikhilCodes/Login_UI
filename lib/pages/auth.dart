import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterlogin/custom_shapes.dart';
import 'package:flutterlogin/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String loginText = "";
  String mode = ""; // sign_in or sign_up
  SharedPreferences prefs;
  List<Widget> inputSections = [];

  Future startUpJobs(BuildContext context) async {
    this.prefs = await SharedPreferences.getInstance();
    if (prefs.getInt("hasAccount") == null) {
      setState(() {
        loginText = "Sign Up";
        inputSections = [
          Row(
            children: <Widget>[
              Icon(Icons.person_pin, color: Colors.black38),
              SizedBox(width: 10),
              Flexible(
                child: TextField(
                  decoration: textFieldDecorUser,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(Icons.lock_outline, color: Colors.black38),
              SizedBox(width: 10),
              Flexible(
                child: TextField(
                  obscureText: true,
                  decoration: textFieldDecorPassword,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(Icons.lock, color: Colors.black38),
              SizedBox(width: 10),
              Flexible(
                child: TextField(
                  obscureText: true,
                  decoration: textFieldDecorConfirmPassword,
                ),
              ),
            ],
          ),
        ];
      });
      mode = "sign_up";
    } else {
      setState(() {
        loginText = "Sign Up";
        inputSections = [
          Text("Email/Phone"),
          TextField(),
          Text("Password"),
          TextField(),
        ];
      });
      mode = "sign_in";
    }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              child: CustomPaint(
                painter: TopSection(),
                child: Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    loginText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.15),
                    child: Container(
                      padding: EdgeInsets.all(30),
                      margin: EdgeInsets.only(top: 15, bottom: 15),
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(100),
                            bottomRight: Radius.circular(100)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black45,
                              blurRadius: 5,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: inputSections,
                      ),
                    ),
                  ),
                  Positioned(
                    right: MediaQuery.of(context).size.width * 0.075,
                    child: FloatingActionButton(
                      child: Icon(Icons.arrow_forward),
                      onPressed: () {
                        print("Pressed");
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              child: CustomPaint(
                painter: BottomSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
