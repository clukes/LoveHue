import 'package:cloud_firestore/cloud_firestore.dart';

//Source: https://firebase.google.com/docs/firestore/manage-data/delete-data
/// Returns a list of commit promises, that delete a whole collection by deleting all it's contained documents.
Future<List<Future<void>>> deleteCollection(CollectionReference collectionReference,
    {int batchSize = 500, FirebaseFirestore? firestore}) async {
  //TODO: Perform this with a callable cloud function instead. https://firebase.google.com/docs/firestore/solutions/delete-collections
  firestore ??= FirebaseFirestore.instance;
  QuerySnapshot snapshot = await collectionReference.limit(batchSize).get();
  List<DocumentSnapshot> documents = snapshot.docs;
  List<Future<void>> commitBatchPromises = [];
  while (documents.isNotEmpty) {
    WriteBatch writeBatch = firestore.batch();
    for (DocumentSnapshot document in documents) {
      writeBatch.delete(document.reference);
    }
    commitBatchPromises.add(writeBatch.commit());
    snapshot = await collectionReference.limit(batchSize).get();
    documents = snapshot.docs;
  }
  return commitBatchPromises;
}
