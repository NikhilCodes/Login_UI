import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlogin/globaldata.dart';
import 'package:flutterlogin/pages/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, @required this.stream}) : super(key: key);

  final stream;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences prefs;
  var actionButtonIcon;

  onLogOut() async {
    showLoggingOut(context);

    prefs.setBool("isSignedIn", false);
    await _auth.signOut();

    GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthPage()));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      actionButtonIcon = Icon(Icons.more_vert);
    });
  }
  
  void postBuildCallback() async {
    prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("isFirstTimeUser")) {
      showTutorial(context);
      prefs.setBool("isFirstTimeUser", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => postBuildCallback());

    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 13),
            child: PopupMenuButton(
              child: actionButtonIcon,
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: GestureDetector(
                    child: Text("Tutorial"),
                    onTap: () => showTutorial(context),
                  ),
                ),
                PopupMenuItem(
                  child: GestureDetector(
                    child: Text("Sign Out"),
                    onTap: onLogOut,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: StreamBuilder(
          stream: widget.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(),
                ),
              );
            return Builder(builder: (context) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "User Details",
                    style: TextStyle(color: Colors.blue, fontSize: 50),
                  ),
                  Container(
                    height: 5,
                    width: MediaQuery.of(context).size.width * 0.7,
                    color: Colors.indigo,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "UserName: " + snapshot.data["username"],
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Text(
                    "Skill: " + snapshot.data["your_skill"],
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Text(
                    "MP: " + snapshot.data["MP"],
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              );
            });
          },
        ),
      ),
    );
  }
}
