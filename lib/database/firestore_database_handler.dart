// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:relationship_bars/models/relationship_bar_model.dart';
// import 'package:relationship_bars/pages/your_bars_page.dart';
// import 'package:relationship_bars/providers/application_state.dart';
// import 'package:relationship_bars/resources/authentication.dart';
// import 'package:relationship_bars/resources/database_and_table_names.dart';
//
// Future<void> updateBarsInOnlineDatabase(List<RelationshipBar> relationshipBars, ApplicationLoginState loginState) async {
//   if (loginState != ApplicationLoginState.loggedIn) {
//     throw Exception('Must be logged in');
//   }
//   String userId = FirebaseAuth.instance.currentUser!.uid;
//   RelationshipBarDao dao = RelationshipBarDao(yourRelationshipBarsTableName);
//   Map <String, dynamic> data = <String, dynamic>{
//     'name': FirebaseAuth.instance.currentUser!.displayName,
//     'relationshipBars': dao.toList(relationshipBars),
//     'timestamp': DateTime.now().millisecondsSinceEpoch,
//   };
//   return await FirebaseFirestore.instance
//       .collection(userBarsCollection)
//       .doc(userId)
//       .set(data, SetOptions(merge: true));
// }
//
// Future<DocumentSnapshot<Map<String, dynamic>>> retrieveUsersCollectionInOnlineDatabase(ApplicationLoginState loginState) async {
//   if (loginState != ApplicationLoginState.loggedIn) {
//     throw Exception('Must be logged in');
//   }
//   String userId = FirebaseAuth.instance.currentUser!.uid;
//   return await FirebaseFirestore.instance
//       .collection(userBarsCollection)
//       .doc(userId)
//       .get();
// }
