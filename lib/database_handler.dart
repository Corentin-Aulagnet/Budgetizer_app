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

  static String expensesTableName = 'expenses';
  static String categoriesTableName = 'categories';

  static List<Expenditure> expendituresList = List.empty(growable: true);
  static List<CategoryDescriptor> categoriesList = List.empty(growable: true);

  static DateTime defaultDate = DateTime(1970);

  late Database db;

  DatabaseHandler._privateConstructor();

  static final DatabaseHandler _instance =
      DatabaseHandler._privateConstructor();

  factory DatabaseHandler() {
    return _instance;
  }

  Future<void> InitializeDatabaseConnexion() async {
    //final file = File(join(await getDatabasesPath(), databaseName));
    //await file.delete();

    db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), databaseName),
      version: 1,
      onCreate: (Database db, int version) async {
        // Run the CREATE TABLE statement on the database
        await db.execute(
            'CREATE TABLE $categoriesTableName (id INTEGER PRIMARY KEY, name TEXT, descriptors TEXT, icon TEXT, color TEXT)');
        await db.execute(
            'CREATE TABLE $expensesTableName (id INTEGER PRIMARY KEY, title TEXT,  categoryID INTEGER, value DOUBLE, date DATE, FOREIGN KEY (categoryID) REFERENCES $categoriesTableName (id)  )');
      },
    );

    print('db init done');
    await LoadCategories();
  }

  static Future<List<Expenditure>> fetchData() async {
    print('fetch data');
    // Open the database
    Database db = await openDatabase(
        join(await getDatabasesPath(), databaseName),
        version: 1);

    // Read the data from the database

    var data = await db.query(
      expensesTableName,
      orderBy: "date DESC",
    );

    //Creates a data container with the Expenditures
    expendituresList.clear();
    for (var element in data) {
      expendituresList.add(Expenditure(
          dataBaseId: int.parse(element['id'].toString()),
          title: element['title'].toString(),
          category:
              MatchCategory(int.parse(element['categoryID'].toString())) ??
                  CategoryDescriptor.Error(),
          value: double.parse(element['value'].toString()),
          date: DateTime.parse(element['date'].toString())));
    }
    // Return the data
    return expendituresList;
  }

  Future<void> InsertData(Expenditure expenditure) async {
    Map<String, dynamic> mapToInsert = {
      'title': expenditure.title,
      'categoryID': expenditure.category.id,
      'value': expenditure.value,
      'date': expenditure.date.toIso8601String()
    };
    await db.insert(expensesTableName, mapToInsert);
  }

  Future<void> UpdateData(Expenditure expenditure) async {
    Map<String, dynamic> mapToInsert = {
      'title': expenditure.title,
      'categoryID': expenditure.category.id,
      'value': expenditure.value,
      'date': expenditure.date.toIso8601String()
    };
    if (expenditure.dataBaseId == -1) {
      //No expenses to modify in database
      //Insert a new expense
      await InsertData(expenditure);
    } else {
      await db.update(expensesTableName, mapToInsert,
          where: 'id = ?', whereArgs: [expenditure.dataBaseId]);
    }
  }

  Future<void> DeleteExpense(Expenditure exp) async {
    expendituresList.remove(exp);
    int id = exp.dataBaseId;
    await db.delete(expensesTableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> RegenerateDatabase() async {
    db.delete(expensesTableName, where: null);
    expendituresList.clear();
  }

  Future<void> DeleteCategories() async {
    db.delete(categoriesTableName, where: null);
    final file = File(join(await getDatabasesPath(), categoriesSaveFileName));
    categoriesList.clear();
  }

  Future<void> DeleteCategory(CategoryDescriptor category) async {
    categoriesList.remove(category);
    int categoryID = category.id;
    await db
        .delete(categoriesTableName, where: 'id = ?', whereArgs: [categoryID]);
    await db.update(expensesTableName, {'categoryID': '-1'},
        where: 'categoryID = ?', whereArgs: [categoryID]);
  }

  Future<void> SaveCategory(CategoryDescriptor category) async {
    print(category);
    categoriesList.add(category);
    Map<String, dynamic> mapToInsert = {};
    print('Category saved : ${category}');
    mapToInsert['name'] = category.name;
    mapToInsert['descriptors'] = category.descriptors.join('-');
    mapToInsert['icon'] = category.emoji;
    //Updates the id of the category in the app
    categoriesList.last.id = await db.insert(categoriesTableName, mapToInsert);
  }

  Future<void> LoadCategories() async {
    // Read the data from the database
    var data = await db.query(categoriesTableName);

    categoriesList.clear();
    for (var row in data) {
      CategoryDescriptor category = CategoryDescriptor(
          id: int.parse(row['id'].toString()),
          emoji: row['icon'].toString(),
          name: row['name'].toString(),
          descriptors: row['descriptors'].toString().split('-'));
      categoriesList.add(category);
    }
  }

  static CategoryDescriptor? MatchCategory(int id) {
    for (CategoryDescriptor category in categoriesList) {
      if (category.id == id) {
        return category;
      } else if (category.id == -1) {
        return CategoryDescriptor.Error();
      }
    }
  }

  static int CountExpensesInCategory(CategoryDescriptor category) {
    return expendituresList
        .where((element) => element.category.id == category.id)
        .length;
  }
}
