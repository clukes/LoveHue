// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
// import 'package:relationship_bars/utils/colors.dart';
// import 'package:relationship_bars/widgets/buttons.dart';
//
// import '../providers/application_state.dart';
// import '../resources/authentication.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Login/Register'),
//         ),
//         body: SafeArea(
//             child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 32),
//           width: double.infinity,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               /* TODO: Replace with proper app logo */
//               const SizedBox(height: 64),
//               SvgPicture.asset('assets/logo.svg', height: 64),
//               Flexible(
//                 child: Container(),
//                 flex: 2,
//               ),
//               Consumer<ApplicationState>(
//                 builder: (context, appState, _) => Authentication(
//                   email: appState.email,
//                   loginState: appState.loginState,
//                   startLoginFlow: appState.startLoginFlow,
//                   verifyEmail: appState.verifyEmail,
//                   signInWithEmailAndLink: appState.signInWithEmailAndLink,
//                   cancelRegistration: appState.cancelRegistration,
//                   signOut: appState.signOut,
//                 ),
//               ),
//               const SizedBox(height: 96),
//               const Divider(
//                 height: 8,
//                 thickness: 1,
//                 color: Colors.grey,
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     width: double.infinity,
//                     child: StyledButton(
//                       onPressed: () {},
//                       child: const Text('Don\'t Login'),
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: const Text(
//                       'If you choose not to login you can still create an account later.',
//                       textScaleFactor:
//                           0.9, /* TODO: CHANGE TO DIFFERENT SIZE, RESPONSIVE */
//                     ),
//                   ),
//                 ],
//               ),
//               const Divider(
//                 height: 8,
//                 thickness: 1,
//                 color: Colors.grey,
//               ),
//               Flexible(
//                 child: Container(),
//                 flex: 1,
//               ),
//             ],
//           ),
//         )));
//   }
// }
