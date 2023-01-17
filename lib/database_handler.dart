import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//Only for dev purposes
import 'package:faker/faker.dart';
import 'dart:math';
import 'package:random_date/random_date.dart';
import 'dart:io';

class DatabaseHandler {
  static String databaseName = 'my_database.db';
  static String table_name = 'my_table';

  static Future<void> InitializeDatabaseConnexion() async {
    // Open the database and store the reference.
    Database db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), databaseName),
      version: 1,
      onCreate: (Database db, int version) async {
        // Run the CREATE TABLE statement on the database
        await db.execute(
          'CREATE TABLE $table_name (id INTEGER PRIMARY KEY, title TEXT, value DOUBLE, date DATE)',
        );
        for (int i = 0; i < 100; i++) {
          await db.insert(
            'my_table',
            {
              'title': faker.person.name(),
              'value': Random().nextDouble(),
              'date':
                  RandomDate.withRange(2021, 2022).random().toIso8601String()
            },
            conflictAlgorithm: ConflictAlgorithm.fail,
          );
        }
      },
    );
    db.close();
    print('db init done');
  }

  static Future<List<Map<String, dynamic>>> fetchData() async {
    print('fetch data');
    // Open the database
    Database db = await openDatabase(
        join(await getDatabasesPath(), databaseName),
        version: 1);

    // Read the data from the database
    var data = await db.query(
      table_name,
      orderBy: "date DESC",
    );

    //close the database
    db.close();
    // Return the data
    return data;
  }

  static Future<void> InsertData(Map<String, dynamic> mapToInsert) async {
    // Open the database
    Database db = await openDatabase(
        join(await getDatabasesPath(), databaseName),
        version: 1);
    print(mapToInsert);
    db.insert(table_name, mapToInsert);

    //close the database
    db.close();
  }

  static Future<void> RegenerateDatabase() async {
    final file = File(join(await getDatabasesPath(), databaseName));
    await file.delete();
    await InitializeDatabaseConnexion();
  }
}
