import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import '../responsive/responsive_screen_layout.dart';

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

final providerConfigs = <ProviderConfiguration>[
  EmailLinkProviderConfiguration(actionCodeSettings: acs),
];

Future<void> signInAnonymously(BuildContext context) async {
  /* TODO: HAVE LOADING OVERLAY */
  print("ANON");
  await FirebaseAuth.instance.signInAnonymously();
  if (FirebaseAuth.instance.currentUser != null) {
    afterSignIn(context);
  } else {
    /* TODO: Display Error */
    print("Sign In Error.");
  }
  print("ANON DONE");
}

void afterSignIn(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => responsiveLayout), (route) => false);
}

// Future<void> _linkCredentials(
//     BuildContext context,
//     CredentialReceived state,
//     ) async {
//   final _auth = FirebaseAuth.instance;
//   print("Credentials link");
//   await _auth.currentUser!.linkWithCredential(state.credential).catchError((error, stackTrace) { print(error); });
// }
//
// Future<void> convertAnonSignInToEmail (BuildContext context) async {
//   Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) {
//           return FlutterFireUIActions(
//             actions: [
//               AuthStateChangeAction<CredentialReceived>(_linkCredentials),
//               AuthStateChangeAction<CredentialLinked>((context, _) async {
//                 print("Signed in");
//                 afterSignIn(context);
//               }),
//             ],
//             child: EmailLinkSignInScreen(
//               config: providerConfigs.firstWhere((e) => e is EmailLinkProviderConfiguration) as EmailLinkProviderConfiguration,
//             ),
//           );
//         },
//       )
//   );
//   //     FirebaseAuth auth = FirebaseAuth.instance;
//   // await showDifferentMethodSignInDialog(context: context,
//   //     availableProviders: ["email_link", "phone"],
//   //     providerConfigs: providerConfigs);
//   // await auth.currentUser!.reload();
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // User is not signed in
//         if (!snapshot.hasData) {
//           return const SignInPage();
//         }
//
//         // Render your application if authenticated
//         return const YourBars();
//       },
//     );
//   }
// }

// class Authentication extends StatefulWidget {
//   final ApplicationLoginState loginState;
//   final String? email;
//   final void Function() startLoginFlow;
//   final Future<void> Function(
//     String email,
//     void Function(FirebaseAuthException e) error,
//   ) verifyEmail;
//   final Future<void> Function(
//     String emailLink,
//     void Function(FirebaseAuthException e) errorCallback,
//   ) signInWithEmailAndLink;
//   final void Function() cancelRegistration;
//   final void Function() signOut;
//
//   const Authentication({
//     required this.loginState,
//     required this.email,
//     required this.startLoginFlow,
//     required this.verifyEmail,
//     required this.signInWithEmailAndLink,
//     required this.cancelRegistration,
//     required this.signOut,
//   });
//
//   @override
//   _AuthenticationState createState() => _AuthenticationState();
// }
//
// class _AuthenticationState extends State<Authentication> {
//   @override
//   Widget build(BuildContext context) {
//     switch (widget.loginState) {
//       case ApplicationLoginState.loggedOut:
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           child: StyledButton(
//             onPressed: () {
//               widget.startLoginFlow();
//             },
//             child: const Text('Login'),
//           ),
//         );
//       case ApplicationLoginState.emailAddress:
//         return EmailForm(
//             callback: (email) => widget.verifyEmail(
//                 email, (e) => showErrorDialog(context, 'Invalid email', e)));
//       case ApplicationLoginState.awaitEmailLink:
//         return Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.only(bottom: 24.0),
//               child: Text(
//                   'Email sent to: ${widget.email}.\nClick link in your email to sign in.'),
//             ),
//             const Padding(
//               padding: EdgeInsets.only(bottom: 8.0),
//               child: Text(
//                 'Make sure to check your spam/junk folder.\nIf email does not arrive, click button below to re-enter your email.',
//                 textScaleFactor: 0.9,
//               ),
//             ),
//             StyledButton(
//               onPressed: () {
//                 widget.cancelRegistration();
//               },
//               child: const Text('Re-enter Email'),
//             ),
//           ],
//         );
//       case ApplicationLoginState.loggedIn:
//         return Column(
//           children: [
//             StyledButton(
//               onPressed: () {
//                 widget.signOut();
//               },
//               child: const Text('Logout'),
//             ),
//             const SizedBox(height: 30),
//             StyledButton(
//               onPressed: _pushEnter,
//               child: const Text('Enter App'),
//             ),
//           ],
//         );
//       default:
//         return Row(
//           children: const [
//             Text("Internal error, this shouldn't happen..."),
//           ],
//         );
//     }
//   }
//
//   void _pushEnter() {
//     Navigator.pushNamed(context, '/yours');
//   }
//
//   void showErrorDialog(BuildContext context, String title, Exception e) {
//     showDialog<void>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             title,
//             style: const TextStyle(fontSize: 24),
//           ),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text(
//                   '${(e as dynamic).message}',
//                   style: const TextStyle(fontSize: 18),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             StyledButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text(
//                 'OK',
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class EmailForm extends StatefulWidget {
//   const EmailForm({required this.callback});
//   final void Function(String email) callback;
//   @override
//   _EmailFormState createState() => _EmailFormState();
// }
//
// /* TODO: FIX NEXT BUTTON GOING OFFSCREEN WHEN KEYBOARD POPS UP */
// class _EmailFormState extends State<EmailForm> {
//   final _formKey = GlobalKey<FormState>(debugLabel: '_EmailFormState');
//   final _controller = TextEditingController();
//
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(bottom: 12),
//           child: Header('Sign in with email'),
//         ),
//         Form(
//           key: _formKey,
//           child: SizedBox(
//             width: double.infinity,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 TextFormFieldInput(
//                   textEditingController: _controller,
//                   textInputType: TextInputType.emailAddress,
//                   hintText: 'Enter your email',
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return 'Enter your email address to continue';
//                     }
//                     return null;
//                   },
//                 ),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.only(top: 12),
//                   child: StyledButton(
//                     onPressed: () async {
//                       if (_formKey.currentState!.validate()) {
//                         widget.callback(_controller.text);
//                       }
//                     },
//                     child: const Text('NEXT'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
