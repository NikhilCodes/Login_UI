import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutterlogin/pages/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpEntryPage extends StatefulWidget {
  OtpEntryPage({Key key, @required this.phoneNumber}) : super(key: key);

  final String phoneNumber;

  @override
  State<StatefulWidget> createState() => _OtpEntryState();
}

class _OtpEntryState extends State<OtpEntryPage> {
  final TextEditingController _pinEditingController = TextEditingController();
  var verificationId;

  SharedPreferences prefs;
  FirebaseAuth _auth = FirebaseAuth.instance;

  startUpJobs(context) async {
    prefs = await SharedPreferences.getInstance();
    _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: Duration(seconds: 60),
      verificationCompleted: (user) => print("Verfication Completed!"),
      verificationFailed: (authException) =>
          print("Failed!\nMessage:\n${authException.message}"),
      codeSent: (verificationId, [forceResendingToken]) {
        print("Code Sent to ${widget.phoneNumber}");
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (verificationId) => print("Time Out!"),
    );
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => startUpJobs(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Verfication Code",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              Text(
                "Please enter the OTP sent\n    on your phonenumber.",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              PinInputTextField(
                pinLength: 6,
                autoFocus: true,
                controller: _pinEditingController,
                decoration: UnderlineDecoration(
                  enteredColor: Colors.white,
                  color: Colors.blue.shade300,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                onChanged: (pin) async {
                  if (pin.length == 6) {
                    var _credential = PhoneAuthProvider.getCredential(
                      verificationId: verificationId,
                      smsCode: pin.trim(),
                    );
                    try {
                      FirebaseUser _user = await _auth.currentUser();
                      await _user.updatePhoneNumberCredential(_credential);
                      await _user.reload();
                      final _result =
                          await _auth.signInWithCredential(_credential);
                      print(_result.user.email);
                      if (_result != null) {
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
                    } catch (e) {
                      if (e == PlatformException &&
                          e.code == "ERROR_INVALID_VERIFICATION_CODE") {
                        print("Invalid Code!");
                      }
                      print(e.toString());
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
