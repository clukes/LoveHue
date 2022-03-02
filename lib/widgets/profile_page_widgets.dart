import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/link_code_firestore_collection_model.dart';
import '../models/userinfo_firestore_collection_model.dart';
import '../pages/sign_in_page.dart';

Future<void> showAlertDialog({
  required BuildContext context,
  Widget yesButtonText = const Text("Yes"),
  Widget noButtonText = const Text("No"),
  required Widget alertTitle,
  required Widget alertContent,
  void Function()? yesPressed,
  void Function()? noPressed,
}) async {
  Widget noButton = TextButton(
    child: noButtonText,
    onPressed: noPressed,
  );

  Widget yesButton = TextButton(
    child: yesButtonText,
    onPressed: yesPressed,
  );

  AlertDialog alert = AlertDialog(
    title: alertTitle,
    content: alertContent,
    actions: [
      noButton,
      yesButton,
    ],
  );

  // show the dialog
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<void> showUnlinkAlertDialog(BuildContext context, String partnerName, String partnerLinkCode) async {
  const String yesButtonText = "Unlink";
  const String noButtonText = "Cancel";
  const double partnerInfoScaleFactor = 0.95;
  const double errorScaleFactor = 0.8;
  String? _errorMsg;
  StateSetter? _setState;
  return showAlertDialog(
    context: context,
    yesButtonText: const Text(yesButtonText),
    noButtonText: const Text(noButtonText),
    alertTitle: const Text("Unlink from partner"),
    alertContent: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      _setState = setState;
      return SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text("Are you sure you would like to unlink from your partner?\n"),
            Text(
              "Partner Name: $partnerName\n"
              "Partner Code: $partnerLinkCode",
              textScaleFactor: partnerInfoScaleFactor,
            ),
            if (_errorMsg != null)
              Text(
                "\n${_errorMsg!}",
                textScaleFactor: errorScaleFactor,
              )
          ],
        ),
      );
    }),
    yesPressed: () async {
      await LinkCode.unlink().then((_) {
        Navigator.pop(context, yesButtonText);
      }).catchError((error) {
        print(error);
        if (_setState != null) {
          _setState!(() {
            _errorMsg = "Error: $error";
          });
        }
      });
    },
    noPressed: () => Navigator.pop(context, noButtonText),
  );
}

Future<void> showDeleteAlertDialog(BuildContext context) async {
  const String yesButtonText = "Delete";
  const String noButtonText = "Cancel";
  const double noteScaleFactor = 0.8;
  const double errorScaleFactor = 0.8;

  String? _errorMsg;
  StateSetter? _setState;
  return showAlertDialog(
    context: context,
    yesButtonText: const Text(yesButtonText),
    noButtonText: const Text(noButtonText),
    alertTitle: const Text("Delete Account"),
    alertContent: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      _setState = setState;
      return SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text("Are you sure you would like to delete your account?\n"),
            const Text("(All your data will be permanently deleted)", textScaleFactor: noteScaleFactor),
            if (_errorMsg != null)
              Text(
                "\n${_errorMsg!}",
                textScaleFactor: errorScaleFactor,
              )
          ],
        ),
      );
    }),
    yesPressed: () async {
      await deleteAccount(context).then((_) {
        Navigator.pop(context, yesButtonText);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SignInPage(),
        ));
      }).catchError((error) {
        print(error);
        if (_setState != null) {
          _setState!(() {
            _errorMsg = "Error: $error";
          });
        }
      });
    },
    noPressed: () => Navigator.pop(context, noButtonText),
  );
}

Future<void> deleteAccount(BuildContext context) async {
  return UserInformation.deleteUserData(context).then((_) {
    FirebaseAuth.instance.currentUser?.delete();
  });
}
