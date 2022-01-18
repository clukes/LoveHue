import 'dart:async';

import 'package:relationship_bars/Database/relationship_bar_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  bool isInitialized = false;
  late Database _db;

  Future<Database> db() async {
    if (!isInitialized) await _initializeDB();
    return _db;
  }

  Future<Database> _initializeDB() async {
    // Open the database and store the reference.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'relationshipBars.db'),
      // When the database is first created, create a table to store bars.
      onCreate: (Database db, version) async {
        // Run the CREATE TABLE statement on the database.
        await RelationshipBarDao('YourRelationshipBars').createTable(db);
        await RelationshipBarDao('PartnersRelationshipBars').createTable(db);
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    return database;
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
  List<T> fromList(List<Map<String,dynamic>> query);
  Map<String, dynamic> toMap(T object);
}