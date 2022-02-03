import 'package:flutter/material.dart';

Future<void> showAlertDialog(
    {required BuildContext context,
    Widget yesButtonText = const Text("Yes"),
    Widget noButtonText = const Text("No"),
    required Widget alertTitle,
    required Widget alertText,
    void Function()? yesPressed,
      void Function()? noPressed}) async {
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
    content: alertText,
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
  return showAlertDialog(
      context: context,
      yesButtonText: const Text("Unlink"),
      noButtonText: const Text("Cancel"),
      alertTitle: const Text("Unlink from partner"),
      alertText: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text("Are you sure you would like to unlink from your partner?\n"),
            Text(
                "Partner Name: $partnerName"
                "Partner Code: $partnerLinkCode",
                textScaleFactor: partnerInfoScaleFactor,
            )
          ],
        ),
      ),
      yesPressed: () {
        //unlinkPartner()
        Navigator.pop(context, yesButtonText);
        }, //TODO: Unlink partner
      noPressed: () => Navigator.pop(context, noButtonText),
  );
}