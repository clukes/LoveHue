import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/sign_in_page.dart';
import '../providers/user_info_state.dart';
import '../resources/authentication_info.dart';

/// Shows an alert dialog with yes and no buttons.
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

/// A dialog to unlink from partner.
class UnlinkAlertDialog {
  UnlinkAlertDialog();

  static const String yesButtonText = "Unlink";
  static const String noButtonText = "Cancel";
  static const double partnerInfoScaleFactor = 0.95;
  static const double errorScaleFactor = 0.8;
  String? _errorMsg;
  StateSetter? _setState;

  /// Shows an alert dialog with the unlink partner message.
  Future<void> show(BuildContext context, String partnerName, String partnerLinkCode) async {
    UserInfoState userInfoState = Provider.of<UserInfoState>(context, listen: false);
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
        await userInfoState.unlink().then((_) {
          Navigator.pop(context, yesButtonText);
        }).catchError((error) {
          if (_setState != null) {
            _setState!(() {
              _errorMsg = "Error: $error";
            });
          }
        });
      },
      // Just close the alert dialog if no pressed.
      noPressed: () => Navigator.pop(context, noButtonText),
    );
  }
}

/// A dialog to delete account.
class DeleteAlertDialog {
  DeleteAlertDialog(this.auth, this.authInfo);

  final FirebaseAuth auth;
  final AuthenticationInfo authInfo;

  static const String yesButtonText = "Delete";
  static const String noButtonText = "Cancel";
  static const double noteScaleFactor = 0.8;
  static const double errorScaleFactor = 0.8;

  String? _errorMsg;
  StateSetter? _setState;

  /// Shows an alert dialog with the delete account message.
  Future<void> show(BuildContext context) async {
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
        await _deleteAccount(context, auth, authInfo).then((_) {
          Navigator.pop(context, yesButtonText);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const SignInPage(),
          ));
        }).catchError((error) {
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

  /// Deletes user data in database, then delete [FirebaseAuth] account with [User.delete]
  Future<void> _deleteAccount(BuildContext context, FirebaseAuth auth, AuthenticationInfo authInfo) async {
    return Provider.of<UserInfoState>(context, listen: false).userInfo?.deleteUserData(context, auth, authInfo);
  }
}
