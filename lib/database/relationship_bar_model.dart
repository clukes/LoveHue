import 'package:sqflite/sqflite.dart';

import 'local_database_handler.dart';

List<RelationshipBar> defaultBars = [
  RelationshipBar(label:"Words of Affirmation"),
  RelationshipBar(label:"Quality Time"),
  RelationshipBar(label:"Giving Gifts"),
  RelationshipBar(label:"Acts of Service"),
  RelationshipBar(label:"Physical Touch"),
];

class RelationshipBar {
  final int? id;
  String label;
  int value;

  RelationshipBar({
    this.id,
    required this.label,
    this.value = 100,
  });

  @override
  String toString() {
    return label + ": " + value.toString();
  }
}

class RelationshipBarDao implements Dao<RelationshipBar> {
  final String tableName;
  final String columnId = 'id';
  final String _columnLabel = 'label';
  final String _columnValue = 'value';

  RelationshipBarDao(this.tableName);

  @override
  Future createTable(Database db) async {
    await db.execute('CREATE TABLE IF NOT EXISTS $tableName('
        '$columnId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$_columnLabel TEXT NON NULL UNIQUE, '
        '$_columnValue INTEGER DEFAULT 100)'
    );
    print(tableName);
    Batch batch = db.batch();
    for(RelationshipBar relationshipBar in defaultBars){
      batch.insert(tableName, toMap(relationshipBar));
    }
    await batch.commit(noResult: true);
  }
  
  @override
  RelationshipBar fromMap(Map<String, dynamic> res) {
      return RelationshipBar(id:res[columnId], label:res[_columnLabel], value:res[_columnValue]);
  }

  @override
  Map<String, dynamic> toMap(RelationshipBar bar) {
    return <String, dynamic>{
    columnId: bar.id,
    _columnLabel: bar.label,
   _columnValue: bar.value,
    };
  }

  @override
  List<Map<String,dynamic>> toList(List<RelationshipBar> bars) {
    return bars.map((e) => toMap(e)).toList();
  }

  @override
  List<RelationshipBar> fromList(List<Map<String, dynamic>> query) {
    return query.map((e) => fromMap(e)).toList();
  }
}

class RelationshipBarRepository implements ElementsRepository<RelationshipBar> {
  final String tableName;
  DatabaseHandler databaseHandler;
  late RelationshipBarDao dao;

  RelationshipBarRepository(this.databaseHandler, this.tableName) {
    dao = RelationshipBarDao(tableName);
  }

  // Define a function that inserts bars into the database
  @override
  Future<List<Object?>> insertList(List<RelationshipBar> relationshipBars) async {
    final Database db = await databaseHandler.db();
    Batch batch = db.batch();
    for(var relationshipBar in relationshipBars){
      batch.insert(dao.tableName, dao.toMap(relationshipBar), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    return await batch.commit();
  }

  @override
  Future<RelationshipBar> update(RelationshipBar relationshipBar) async {
    // Get a reference to the database.
    final db = await databaseHandler.db();

    // Update the given bar.
    await db.update(
      dao.tableName,
      dao.toMap(relationshipBar),
      // Ensure that the bar has a matching id.
      where: dao.columnId + ' = ?',
      // Pass the bar's id as a whereArg to prevent SQL injection.
      whereArgs: [relationshipBar.id],
    );
    return relationshipBar;
  }

  @override
  Future<RelationshipBar> delete(RelationshipBar relationshipBar) async {
    // Get a reference to the database.
    final db = await databaseHandler.db();

    // Remove the bar from the database.
    await db.delete(
      dao.tableName,
      // Use a `where` clause to delete a specific bar.
      where: dao.columnId + ' = ?',
      // Pass the bar's id as a whereArg to prevent SQL injection.
      whereArgs: [relationshipBar.id],
    );
    return relationshipBar;
  }


  @override
  // A method that retrieves all bars from a table.
  Future<List<RelationshipBar>> retrieveElements() async {
    print("RETRIEVE 1");
    // Get a reference to the database.
    final db = await databaseHandler.db();

    // Query the table for all the bars.
    final List<Map<String, dynamic>> queryResult = await db.query(dao.tableName);

    // Convert the List<Map<String, dynamic> into a List<RelationshipBar>.
    return dao.fromList(queryResult);
  }
}
