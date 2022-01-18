import 'dart:async';

import 'package:relationship_bars/Database/relationship_bar_model.dart';
import 'package:path/path.dart';
import 'package:relationship_bars/Pages/your_bars_page.dart';
import 'package:sqflite/sqflite.dart';

import '../Pages/partners_bars_page.dart';

class DatabaseHandler {
  late Database _db;

  Future<Database> db() async {
    return await _initializeDB();
  }

  Future<Database> _initializeDB() async {
    print("INITIALIZE DB");
    // Open the database and store the reference.
    _db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'relationshipBars.db'),
      // When the database is first created, create a table to store bars.
      onCreate: (Database db, version) async {
        // Run the CREATE TABLE statement on the database.
        await RelationshipBarDao(yourRelationshipBarsTableName).createTable(db);
        await RelationshipBarDao(partnersRelationshipBarsTableName).createTable(db);
        print("CREATED");
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    return _db;
  }
}

abstract class ElementsRepository<T> {
  Future<List<Object?>> insertList(List<T> element);

  Future<T> update(T element);

  Future<T> delete(T element);

  Future<List<T>> retrieveElements();
}

abstract class Dao<T> {
  //queries

  Future createTable(Database db);

  //abstract mapping methods
  T fromMap(Map<String, dynamic> query);
  Map<String, dynamic> toMap(T object);
  List<T> fromList(List<Map<String,dynamic>> query);
  List<Map<String,dynamic>> toList(List<T> query);
}