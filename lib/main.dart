import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'expenditures-list-view.dart';
import 'add-expenditure-view.dart';
import 'package:faker/faker.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.
  Database database = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'my_database.db'),
    version: 1,
    onCreate: (Database db, int version) async {
      // Run the CREATE TABLE statement on the database
      await db.execute(
        'CREATE TABLE my_table (id INTEGER PRIMARY KEY, title TEXT, value DOUBLE)',
      );
      for(int i =0; i<100;i++){
        await db.insert(
          'my_table',
          {
            'title' : faker.person.name(),
            'value' : Random().nextDouble(),
          },
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
      }
    },
  );
  runApp(MyApp(db : database));
}

class MyApp extends StatelessWidget {
  final Database db;
  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Builder(
        builder: (context)=> DefaultTabController(
            length :2,
            child:
            Scaffold(
              appBar: AppBar(
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.table_rows)),
                    Tab(icon: Icon(Icons.auto_graph)),
                  ],
                ),
                title: const Text('Welcome to Flutter'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {// Add your onPressed code here!
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddExpenditureView()),
                  );
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.add),
              ),
              body: TabBarView(
                children: [
                  ExpenditureTab(db: db),
                  const Icon(Icons.auto_graph),
                ],
              ),
            )
        ),
      ),
    );
  }
}

