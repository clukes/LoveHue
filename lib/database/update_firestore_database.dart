import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/pages/your_bars_page.dart';
import 'package:relationship_bars/resources/authentication.dart';

Future<void> updateBarsInOnlineDatabase(List<RelationshipBar> relationshipBars, ApplicationLoginState loginState) async {
  if (loginState != ApplicationLoginState.loggedIn) {
    throw Exception('Must be logged in');
  }
  String userId = FirebaseAuth.instance.currentUser!.uid;
  RelationshipBarDao dao = RelationshipBarDao(yourRelationshipBarsTableName);
  Map <String, dynamic> data = <String, dynamic>{
    'relationshipBars': dao.toList(relationshipBars),
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'name': FirebaseAuth.instance.currentUser!.displayName,
    'userId': userId,
  };
  return await FirebaseFirestore.instance
      .collection('UserBars')
      .doc(userId)
      .set(data, SetOptions(merge: true));
}
