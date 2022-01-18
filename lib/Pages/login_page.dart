import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application_state.dart';
import '../authentication.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login/Register'),
      ),
      body: ListView(
        children: <Widget>[
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Authentication(
              email: appState.email,
              loginState: appState.loginState,
              startLoginFlow: appState.startLoginFlow,
              verifyEmail: appState.verifyEmail,
              signInWithEmailAndLink: appState.signInWithEmailAndLink,
              cancelRegistration: appState.cancelRegistration,
              signOut: appState.signOut,
            ),
          ),
          const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 24, bottom: 8),
                child: Text(
                    'If you choose not to login you can still create an account later.'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 8),
                child: StyledButton(
                  onPressed: () {},
                  child: const Text('Don\'t Login.'),
                ),
              ),
            ],
          ),
          const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 8),
                child: StyledButton(
                  onPressed: _pushEnter,
                  child: const Text('Enter App.'),
                ),
              ),
            ],
          )

        ],
      ),
    );
  }
  void _pushEnter() {
    Navigator.pushNamed(context, '/yours');
  }
}
