import 'package:cloud_firestore/cloud_firestore.dart';


//Source: https://firebase.google.com/docs/firestore/manage-data/delete-data
Future<List<Future<void>>> deleteCollection(CollectionReference collectionReference, int batchSize) async {
  QuerySnapshot snapshot = await collectionReference.limit(batchSize).get();
  List<DocumentSnapshot> documents = snapshot.docs;
  List<Future<void>> commitBatchPromises = [];
  while (documents.isNotEmpty)
  {
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    for(DocumentSnapshot document in documents)
    {
      print("Deleting document ${document.id}");
      writeBatch.delete(document.reference);
    }
    commitBatchPromises.add(writeBatch.commit());
    snapshot = await collectionReference.limit(batchSize).get();
    documents = snapshot.docs;
  }
  return commitBatchPromises;
}
