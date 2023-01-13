import 'package:flutter/material.dart';
import 'package:shareparts/expenditure-view.dart';
import 'package:sqflite/sqflite.dart';
import 'expenditure.dart';
class ExpenditureTab extends StatelessWidget {
  Database db;
  ExpenditureTab({super.key,required this.db});

  @override
  Widget build(BuildContext context) {
    return Expenditures(db : this.db);
  }
}

class _ExpendituresState extends State<Expenditures> {
  final _expenditures = <Expenditure>[]; //Growable list of Expenditures
  final _biggerFont = const TextStyle(fontSize: 18);
  Database db;

  _ExpendituresState({required this.db});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              var row = snapshot.data?[index];
              Expenditure exp = Expenditure(title: row?['title'], value: row?['value']);
              return ListTile(
                title: Text('$index ${exp.title}'),
                subtitle: Text(exp.value.toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExpenditureView(expenditure: exp)),
                  );
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return CircularProgressIndicator();
      },
    );
  }
}

Future<List<Map<String, dynamic>>> fetchData() async {
  // Open the database
  var database = await openDatabase(
    'my_database.db',
    version: 1,
  );

  // Read the data from the database
  var data = await database.query('my_table');

  // Close the database
  database.close();

  // Return the data
  return data;
}
class Expenditures extends StatefulWidget{
  final Database db;
  const Expenditures({super.key, required this.db});
  @override
  State<Expenditures> createState () => _ExpendituresState(db : this.db);
}