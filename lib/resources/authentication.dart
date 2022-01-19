import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:relationship_bars/utils/colors.dart';
import 'package:relationship_bars/widgets/styled_button.dart';

import '../Widgets/text_form_field_input.dart';

enum ApplicationLoginState {
  loggedOut,
  emailAddress,
  register,
  awaitEmailLink,
  loggedIn,
}

var acs = ActionCodeSettings(
    // URL you want to redirect back to. The domain (www.example.com) for this
    // URL must be whitelisted in the Firebase Console.
    url: 'http://relationshipapp.page.link/',
    // This must be true
    handleCodeInApp: true,
    androidPackageName: 'com.example.relationship_app',
    // installIfNotAvailable
    androidInstallApp: true,
    // minimumVersion
    androidMinimumVersion: '12');

class Header extends StatelessWidget {
  const Header(this.heading);
  final String heading;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          heading,
          style: const TextStyle(fontSize: 24),
        ),
      );
}

class Authentication extends StatefulWidget {
  final ApplicationLoginState loginState;
  final String? email;
  final void Function() startLoginFlow;
  final void Function(
    String email,
    void Function(Exception e) error,
  ) verifyEmail;
  final void Function(
    String emailLink,
    void Function(FirebaseAuthException e) errorCallback,
  ) signInWithEmailAndLink;
  final void Function() cancelRegistration;
  final void Function() signOut;

  const Authentication({
    required this.loginState,
    required this.email,
    required this.startLoginFlow,
    required this.verifyEmail,
    required this.signInWithEmailAndLink,
    required this.cancelRegistration,
    required this.signOut,
  });

  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.loginState) {
      case ApplicationLoginState.loggedOut:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: StyledButton(
            onPressed: () {
              widget.startLoginFlow();
            },
            child: const Text('Login'),
          ),
        );
      case ApplicationLoginState.emailAddress:
        return EmailForm(
            callback: (email) => widget.verifyEmail(
                email, (e) => _showErrorDialog(context, 'Invalid email', e)));
      case ApplicationLoginState.awaitEmailLink:
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text('Email sent to: ${widget.email}.\nClick link in your email to sign in.'),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text('Make sure to check your spam/junk folder.\nIf email does not arrive, click button below to re-enter your email.',
              textScaleFactor: 0.9,),
            ),

            StyledButton(
              onPressed: () {
                widget.cancelRegistration();
              },
              child: const Text('Re-enter Email'),
            ),
          ],
        );
      case ApplicationLoginState.loggedIn:
        return Column(
          children: [
            StyledButton(
              onPressed: () {
                widget.signOut();
              },
              child: const Text('Logout'),
            ),
            const SizedBox(height: 30),
            StyledButton(
              onPressed: _pushEnter,
              child: const Text('Enter App'),
            ),
          ],
        );
      default:
        return Row(
          children: const [
            Text("Internal error, this shouldn't happen..."),
          ],
        );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    errorCallback(e) => _showErrorDialog(context, 'Login Link Error', e);

    print("STATE CHANGED");
    if (state == AppLifecycleState.resumed) {
      final PendingDynamicLinkData? initialLink =
          await FirebaseDynamicLinks.instance.getInitialLink();
      if (initialLink?.link != null) {
        widget.signInWithEmailAndLink(
            initialLink!.link.toString(), errorCallback);
      }
      FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
        final Uri deepLink = dynamicLinkData.link;
        widget.signInWithEmailAndLink(deepLink.toString(), errorCallback);
      }).onError((e) async {
        print('onLinkError');
        print(e.message);
      });
    }
  }

  void _pushEnter() {
    Navigator.pushNamed(context, '/yours');
  }

  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 24),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${(e as dynamic).message}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            StyledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }
}

class EmailForm extends StatefulWidget {
  const EmailForm({required this.callback});
  final void Function(String email) callback;
  @override
  _EmailFormState createState() => _EmailFormState();
}

/* TODO: FIX NEXT BUTTON GOING OFFSCREEN WHEN KEYBOARD POPS UP */
class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_EmailFormState');
  final _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Header('Sign in with email'),
        ),
        Form(
          key: _formKey,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormFieldInput(
                  textEditingController: _controller,
                  textInputType: TextInputType.emailAddress,
                  hintText: 'Enter your email',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your email address to continue';
                    }
                    return null;
                  },
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12),
                  child: StyledButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        widget.callback(_controller.text);
                      }
                    },
                    child: const Text('NEXT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
