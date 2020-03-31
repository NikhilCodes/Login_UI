import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlogin/pages/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, @required this.stream}) : super(key: key);

  final stream;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 13),
            child: PopupMenuButton(
              child: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: GestureDetector(
                    child: Text("Sign Out"),
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove("UID");
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => AuthPage()));
                    },
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
