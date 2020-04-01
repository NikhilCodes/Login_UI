import 'package:flutter/material.dart';

/// Global Constants

final skillSet = [
  "Imperial Darkness",
  "Singularity",
  "Foresight",
  "Evasion",
  "Procrastination",
  "Invisiblity",
  "Accel",
  "Holy Javelin",
  "Artillery Strike",
  "Null Punch",
  "Rich",
  "Sleep",
  "Teleport",
  "Fallen Vision",
];

/// Global Functions

showAlertDialog(BuildContext context, String title, String body) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(body),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}


