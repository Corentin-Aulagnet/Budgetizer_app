import 'package:budgetizer/Icons%20Selector/IconListTile.dart';
import 'package:budgetizer/expenditure.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
//Only for dev purposes
import 'package:faker/faker.dart';
import 'dart:math';
import 'package:random_date/random_date.dart';
import 'dart:io';

class DatabaseHandler {
  static String databaseName = 'my_database.db';
  static String categoriesSaveFileName = 'categories';
  static String tableName = 'my_table';

  static List<Expenditure> expendituresList = List.empty(growable: true);
  static List<CategoryDescriptor> categoriesList = List.empty(growable: true);

  static Future<void> InitializeDatabaseConnexion() async {
    //final file = File(join(await getDatabasesPath(), databaseName));
    //await file.delete();
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
          'CREATE TABLE $tableName (id INTEGER PRIMARY KEY, title TEXT, category TEXT, value DOUBLE, date DATE)',
        ); /*
        for (int i = 0; i < 100; i++) {
          await db.insert(
            'my_table',
            {
              'title': faker.person.name(),
              'category': Random().nextInt(3),
              'value': Random().nextDouble(),
              'date':
                  RandomDate.withRange(2021, 2022).random().toIso8601String()
            },
            conflictAlgorithm: ConflictAlgorithm.fail,
          );
        }*/
      },
    );
    db.close();
    print('db init done');
    LoadCategories();
  }

  static Future<List<Expenditure>> fetchData() async {
    print('fetch data');
    // Open the database
    Database db = await openDatabase(
        join(await getDatabasesPath(), databaseName),
        version: 1);

    // Read the data from the database
    var data = await db.query(
      tableName,
      orderBy: "date DESC",
    );

    //close the database
    db.close();
    //Creates a data container with the Expenditures
    expendituresList.clear();
    for (var element in data) {
      expendituresList.add(Expenditure(
          title: element['title'].toString(),
          category: MatchCategory(element['category'].toString()) ??
              CategoryDescriptor.createPlaceholder(),
          value: double.parse(element['value'].toString()),
          date: DateTime.parse(element['date'].toString())));
    }
    // Return the data
    return expendituresList;
  }

  static Future<void> InsertData(Map<String, dynamic> mapToInsert) async {
    // Open the database
    Database db = await openDatabase(
        join(await getDatabasesPath(), databaseName),
        version: 1);
    print(mapToInsert);
    db.insert(tableName, mapToInsert);

    //close the database
    db.close();
  }

  static Future<void> RegenerateDatabase() async {
    final file = File(join(await getDatabasesPath(), databaseName));
    await file.delete();
    await InitializeDatabaseConnexion();
  }

  static Future<void> DeleteCategories() async {
    final file = File(join(await getDatabasesPath(), categoriesSaveFileName));
    if (file.existsSync()) await file.delete();
    categoriesList.clear();
    if (!file.existsSync()) file.createSync();
  }

  static Future<List<Map<String, dynamic>>> fetchMonthDataByCategory(
      DateTime mmyy) async {
    // Open the database
    Database db = await openDatabase(
        join(await getDatabasesPath(), databaseName),
        version: 1);
    int month = mmyy.month;
    int year = mmyy.year;
    // Read the data from the database
    var data = await db.query(
      tableName,
      groupBy: 'category',
      where: 'MONTH(date) = $month AND YEAR(date) = $year',
    );

    //close the database
    db.close();
    // Return the data
    return data;
  }

  static Future<void> SaveCategory(CategoryDescriptor category) async {
    final file = File(join(await getDatabasesPath(), categoriesSaveFileName));
    if (!file.existsSync()) file.createSync();
    categoriesList.add(category);
    List<Map<String, dynamic>> mapList = List.generate(
        categoriesList.length, (index) => categoriesList[index].toJSON());
    String json = jsonEncode(mapList);
    file.writeAsString(json);
  }

  static Future<void> LoadCategories() async {
    final file = File(join(await getDatabasesPath(), categoriesSaveFileName));
    String json = await file.readAsString();
    if (json.isNotEmpty) {
      List<dynamic> jsonList = (jsonDecode(json));
      categoriesList = List.generate(jsonList.length,
          (index) => CategoryDescriptor.fromJSON(jsonList[index]));
    }
  }

  static CategoryDescriptor? MatchCategory(String hashCode) {
    for (CategoryDescriptor category in categoriesList) {
      if (category.hash == hashCode) {
        return category;
      }
    }
  }
}
