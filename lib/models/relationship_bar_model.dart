import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relationship_bars/resources/database_and_table_names.dart';
import 'package:sqflite/sqflite.dart';

import '../database/local_database_handler.dart';

List<Map<String,String>> defaultBarLabels = [
{'label':'Words of Affirmation'},
{'label':"Quality Time"},
{'label':"Giving Gifts"},
{'label':"Acts of Service"},
{'label':"Physical Touch"},
];

CollectionReference<RelationshipBar> userBarsFirestoreRef(String userID) => FirebaseFirestore.instance
    .collection(userBarsCollection)
    .doc(userID)
    .collection(specificUserBarsCollection)
    .withConverter<RelationshipBar>(
  fromFirestore: (snapshots, _) => RelationshipBar.fromMap(snapshots.data()!),
  toFirestore: (relationshipBar, _) => relationshipBar.toMap(),
);

const defaultBarValue = 100;

class RelationshipBar {
  final String id;
  String label;
  int prevValue;
  int value;
  bool changed;

  RelationshipBar({
      required this.id,
      required this.label,
      this.prevValue = defaultBarValue,
      this.value = defaultBarValue,
      this.changed = false
      });

  int setValue(int newValue) {
    if(newValue != value) {
      prevValue = value;
      value = newValue;
      changed = true;
    }
    return value;
  }

  int resetValue() {
    value = prevValue;
    changed = false;
    return value;
  }

  static List<RelationshipBar> resetBarsChanged(List<RelationshipBar> bars) {
    return bars.map((e) {
      e.changed = false;
      return e;
    }).toList();
  }

  static List<RelationshipBar>? resetBars(List<RelationshipBar> bars) {
    return bars.map((e) {
      e.value = e.prevValue;
      e.changed = false;
      return e;
    }).toList();
  }


  @override
  String toString() {
    return label + ": " + value.toString();
  }

  //Firestore database info
  static const String columnID = 'id';
  static const String columnLabel = 'label';
  static const String columnValue = 'value';
  static const String columnPrevValue = 'prevValue';

  static RelationshipBar fromMap(Map<String, Object?> res) {
    return RelationshipBar(
        id: res[columnID] as String,
        label: res[columnLabel]! as String,
        value: res[columnValue] is int ? res[columnValue] as int : defaultBarValue,
        prevValue: res[columnValue] is int ? res[columnValue] as int : defaultBarValue,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      columnID: id,
      columnLabel: label,
      columnPrevValue: prevValue,
      columnValue: value,
    };
  }

  static List<Map<String, dynamic>> toList(List<RelationshipBar> info) {
    return info.map((e) => e.toMap()).toList();
  }

  static List<RelationshipBar> fromList(List<Map<String, dynamic>> query) {
    return query.map((e) => fromMap(e)).toList();
  }

  static List<RelationshipBar> fromQuerySnapshot(QuerySnapshot<RelationshipBar> snapshot) {
    return snapshot.docs.map((e) => e.data()).toList();
  }

  static Future<List<RelationshipBar>?> firestoreGetBars(String userID) async {
    List<RelationshipBar>? bars;
    bars = await userBarsFirestoreRef(userID)
        .get()
        .then((snapshot) => fromQuerySnapshot(snapshot))
        .catchError((error) { print("Failed to retrieve relationship bar: $error"); return <RelationshipBar>[]; });
    return bars;
  }

  Future<void> firestoreSet(String userID) async {
    return await userBarsFirestoreRef(userID)
        .doc(id)
        .set(this, SetOptions(merge: true))
        .then((value) => print("Relationship Bar Added"))
        .catchError((error) => print("Failed to add user info: $error"));
  }

  static Future<void> firestoreSetList(String userID, List<RelationshipBar> bars) async {
    final CollectionReference<RelationshipBar> ref = userBarsFirestoreRef(userID);
    final WriteBatch batch = FirebaseFirestore.instance.batch();

    for (RelationshipBar bar in bars) {
      batch.set(ref.doc(bar.id), bar, SetOptions(merge: true));
    }
    await batch.commit();
  }

  static Future<void> firestoreAddMap(String userID, List<Map<String, dynamic>> barsData) async {
    final CollectionReference<RelationshipBar> ref = userBarsFirestoreRef(userID);
    final WriteBatch batch = FirebaseFirestore.instance.batch();

    for (Map<String, dynamic> barMap in barsData) {
      DocumentReference<RelationshipBar> doc = ref.doc();
      barMap[columnID] = doc.id;
      batch.set(doc, RelationshipBar.fromMap(barMap), SetOptions(merge: true));
    }
    await batch.commit();
  }

  static Future<void> firestoreUpdateColumns(String userID, String barID, Map<String, dynamic> data) async {
     await userBarsFirestoreRef(userID)
        .doc(barID)
        .update(data)
        .then((value) => print("Relationship Bar Update"))
        .catchError((error) => print("Failed to update relationship bar: $error"));
  }

  Future<void> firestoreDelete(String userID) async {
     await userBarsFirestoreRef(userID)
        .doc(id)
        .delete()
        .then((value) => print("Relationship Bar Deleted"))
        .catchError((error) => print("Failed to delete relationship bar: $error"));
  }
}

// class RelationshipBarDao {
//   final String tableName;
//   final String columnId = 'id';
//   final String _columnLabel = 'label';
//   final String _columnPrevValue = 'prevValue';
//   final String _columnValue = 'value';
//   final String _changed = 'changed';
//
//   RelationshipBarDao(this.tableName);
//
//   @override
//   Future createTable(Database db) async {
//     await db.execute('CREATE TABLE IF NOT EXISTS $tableName('
//         '$columnId INTEGER PRIMARY KEY AUTOINCREMENT, '
//         '$_columnLabel TEXT NON NULL UNIQUE, '
//         '$_columnPrevValue INTEGER DEFAULT 100, '
//         '$_columnValue INTEGER DEFAULT 100, '
//         '$_changed INTEGER DEFAULT 0)');
//     print(tableName);
//     Batch batch = db.batch();
//     for (RelationshipBar relationshipBar in defaultBars) {
//       batch.insert(tableName, toMap(relationshipBar));
//     }
//     await batch.commit(noResult: true);
//   }
//
//   @override
//   RelationshipBar fromMap(Map<String, dynamic> res) {
//     return RelationshipBar(
//         id: res[columnId],
//         label: res[_columnLabel],
//         prevValue: res[_columnPrevValue],
//         value: res[_columnValue],
//         changed: (res[_changed] == 1 || res[_changed] == true));
//   }
//
//   @override
//   Map<String, dynamic> toMap(RelationshipBar bar) {
//     return <String, dynamic>{
//       columnId: bar.id,
//       _columnLabel: bar.label,
//       _columnPrevValue: bar.prevValue,
//       _columnValue: bar.value,
//       _changed: bar.changed
//     };
//   }
//
//   @override
//   List<Map<String, dynamic>> toList(List<RelationshipBar> bars) {
//     return bars.map((e) => toMap(e)).toList();
//   }
//
//   @override
//   List<RelationshipBar> fromList(List<Map<String, dynamic>> query) {
//     return query.map((e) => fromMap(e)).toList();
//   }
//
//   static List<RelationshipBar> resetBarsChanged(List<RelationshipBar> bars) {
//     return bars.map((e) {
//       e.changed = false;
//       return e;
//     }).toList();
//   }
// }
//
// class RelationshipBarRepository implements ElementsRepository<RelationshipBar> {
//   final String tableName;
//   late RelationshipBarDao dao;
//   final DatabaseHandler localDBBarsHandler = DatabaseHandler(dbName: relationshipBarsDatabase);
//
//   RelationshipBarRepository(this.tableName) {
//     dao = RelationshipBarDao(tableName);
//   }
//
//   // Define a function that inserts bars into the database
//   @override
//   Future<List<Object?>> insertList(
//       List<RelationshipBar> relationshipBars) async {
//     final Database db = await localDBBarsHandler.db();
//     Batch batch = db.batch();
//     for (var relationshipBar in relationshipBars) {
//       batch.insert(dao.tableName, dao.toMap(relationshipBar),
//           conflictAlgorithm: ConflictAlgorithm.replace);
//     }
//     return await batch.commit();
//   }
//
//   @override
//   Future<RelationshipBar> update(RelationshipBar relationshipBar) async {
//     // Get a reference to the database.
//     final db = await localDBBarsHandler.db();
//     // Update the given bar.
//     await db.update(
//       dao.tableName,
//       dao.toMap(relationshipBar),
//       // Ensure that the bar has a matching id.
//       where: dao.columnId + ' = ?',
//       // Pass the bar's id as a whereArg to prevent SQL injection.
//       whereArgs: [relationshipBar.id],
//     );
//     return relationshipBar;
//   }
//
//   @override
//   Future<RelationshipBar> delete(RelationshipBar relationshipBar) async {
//     // Get a reference to the database.
//     final db = await localDBBarsHandler.db();
//
//     // Remove the bar from the database.
//     await db.delete(
//       dao.tableName,
//       // Use a `where` clause to delete a specific bar.
//       where: dao.columnId + ' = ?',
//       // Pass the bar's id as a whereArg to prevent SQL injection.
//       whereArgs: [relationshipBar.id],
//     );
//     return relationshipBar;
//   }
//
//   @override
//   // A method that retrieves all bars from a table.
//   Future<List<RelationshipBar>> retrieveElements() async {
//     print("RETRIEVE 1");
//     // Get a reference to the database.
//     final db = await localDBBarsHandler.db();
//
//     // Query the table for all the bars.
//     final List<Map<String, dynamic>> queryResult =
//         await db.query(dao.tableName);
//
//     // Convert the List<Map<String, dynamic> into a List<RelationshipBar>.
//     return dao.fromList(queryResult);
//   }
// }
