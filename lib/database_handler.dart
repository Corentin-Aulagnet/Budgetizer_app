import 'package:budgetizer/Icons_Selector/category_utils.dart';
import 'package:budgetizer/expenditure.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:budgetizer/home.dart';
//Only for dev purposes

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

  Future<void> initializeDatabaseConnexion() async {
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
    await loadCategories();
    await fetchData();
  }

  Future<List<Expenditure>> fetchData() async {
    // Open the database
    /*Database db = await openDatabase(
        join(await getDatabasesPath(), databaseName),
        version: 1);
*/
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
              matchCategory(int.parse(element['categoryID'].toString())) ??
                  CategoryDescriptor.error(),
          value: double.parse(element['value'].toString()),
          date: DateTime.parse(element['date'].toString())));
    }
    // Return the data
    return expendituresList;
  }

  Future<List<String>> fetchDates() async {
    var data = await db.query(expensesTableName,
        columns: ['date'], orderBy: "date DESC", groupBy: 'date');
    List<String> dates = List.empty(growable: true);
    for (var element in data) {
      dates.add(element['date'].toString());
    }
    return dates;
  }

  Future<void> insertData(Expenditure expenditure) async {
    Map<String, dynamic> mapToInsert = {
      'title': expenditure.title,
      'categoryID': expenditure.category.id,
      'value': expenditure.value,
      'date': expenditure.date.toIso8601String()
    };
    await db.insert(expensesTableName, mapToInsert);
  }

  Future<void> updateData(Expenditure expenditure) async {
    Map<String, dynamic> mapToInsert = {
      'title': expenditure.title,
      'categoryID': expenditure.category.id,
      'value': expenditure.value,
      'date': expenditure.date.toIso8601String()
    };
    if (expenditure.dataBaseId == -1) {
      //No expenses to modify in database
      //Insert a new expense
      await insertData(expenditure);
    } else {
      await db.update(expensesTableName, mapToInsert,
          where: 'id = ?', whereArgs: [expenditure.dataBaseId]);
    }
  }

  Future<void> deleteExpense(Expenditure exp) async {
    expendituresList.remove(exp);
    int id = exp.dataBaseId;
    await db.delete(expensesTableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> regenerateDatabase() async {
    db.delete(expensesTableName, where: null);
    expendituresList.clear();
  }

  Future<void> deleteCategories() async {
    db.delete(categoriesTableName, where: null);
    categoriesList.clear();
  }

  Future<void> deleteCategory(CategoryDescriptor category) async {
    categoriesList.remove(category);
    int categoryID = category.id;
    await db
        .delete(categoriesTableName, where: 'id = ?', whereArgs: [categoryID]);
    await db.update(expensesTableName, {'categoryID': '-1'},
        where: 'categoryID = ?', whereArgs: [categoryID]);
  }

  Future<void> saveCategory(CategoryDescriptor category) async {
    categoriesList.add(category);
    Map<String, dynamic> mapToInsert = {};
    mapToInsert['name'] = category.name;
    mapToInsert['descriptors'] = category.descriptors.join('-');
    mapToInsert['icon'] = category.emoji;
    //Updates the id of the category in the app
    categoriesList.last.id = await db.insert(categoriesTableName, mapToInsert);
  }

  Future<void> loadCategories() async {
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

  static CategoryDescriptor? matchCategory(int id) {
    for (CategoryDescriptor category in categoriesList) {
      if (category.id == id) {
        return category;
      } else if (category.id == -1) {
        return CategoryDescriptor.error();
      }
    }
    return null; //Should go here only if categoriesList is empty
  }

  static int countExpensesInCategory(CategoryDescriptor category) {
    return expendituresList
        .where((element) => element.category.id == category.id)
        .length;
  }
}
