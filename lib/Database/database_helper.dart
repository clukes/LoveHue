import 'dart:async';

import 'package:relationship_bars/Database/relationship_bar_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

List<RelationshipBar> defaultBars = [
  RelationshipBar(label:"Words of Affirmation"),
  RelationshipBar(label:"Quality Time"),
  RelationshipBar(label:"Giving Gifts"),
  RelationshipBar(label:"Acts of Service"),
  RelationshipBar(label:"Physical Touch"),
];

class DatabaseHandler {
  Future<Database> initializeDB() async {
    // Open the database and store the reference.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'relationshipBars.db'),
      // When the database is first created, create a table to store bars.
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute(
          'CREATE TABLE IF NOT EXISTS RelationshipBars(id INTEGER PRIMARY KEY AUTOINCREMENT, label TEXT NON NULL UNIQUE, value INTEGER DEFAULT 100)',
        );
        Batch batch = db.batch();
        for(var relationshipBar in defaultBars){
          batch.insert('RelationshipBars', relationshipBar.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    /* Add initial default bars */
    return database;
  }

  // Define a function that inserts bars into the database
  Future<List<Object?>> insertRelationshipBars(List<dynamic> relationshipBars) async {
    int result = 0;
    final Database db = await initializeDB();
    Batch batch = db.batch();
    for(var relationshipBar in relationshipBars){
      batch.insert('RelationshipBars', relationshipBar.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    return await batch.commit();
  }


  // A method that retrieves all bars from a table.
  Future<List<RelationshipBar>> retrieveRelationshipBars() async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Query the table for all the bars.
    final List<Map<String, dynamic>> queryResult = await db.query('RelationshipBars');

    // Convert the List<Map<String, dynamic> into a List<RelationshipBar>.
    return queryResult.map((e) => RelationshipBar.fromMap(e)).toList();

  }

  Future<void> updateRelationshipBar(RelationshipBar relationshipBar) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Update the given bar.
    await db.update(
      'RelationshipBars',
      relationshipBar.toMap(),
      // Ensure that the bar has a matching id.
      where: 'id = ?',
      // Pass the bar's id as a whereArg to prevent SQL injection.
      whereArgs: [relationshipBar.id],
    );
  }

  Future<void> deleteRelationshipBar(int id) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Remove the bar from the database.
    await db.delete(
      'RelationshipBars',
      // Use a `where` clause to delete a specific bar.
      where: 'id = ?',
      // Pass the bar's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

}