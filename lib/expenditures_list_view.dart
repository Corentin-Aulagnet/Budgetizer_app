import 'package:flutter/material.dart';
import 'package:budgetizer/expenditure_view.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:budgetizer/expenditure.dart';
import 'package:intl/intl.dart';

class ExpendituresListView extends StatelessWidget {
  ExpendituresListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expenditures();
  }
}

class _ExpendituresState extends State<Expenditures> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: refreshView,
        child: Scaffold(
            body: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHandler.fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  var row = snapshot.data?[index];
                  Expenditure exp = Expenditure(
                      title: row?['title'],
                      value: row?['value'],
                      date: DateTime.parse(row?['date']));
                  return ListTile(
                    title: Text(
                        '${DateFormat.yMd('fr_Fr').format(exp.date)} ${exp.title}'),
                    subtitle: Text(exp.value.toString()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ExpenditureView(expenditure: exp)),
                      );
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    ListTile(title: Text('Error: ${snapshot.error}'))
                  ]);
            }
            return const Center(child: CircularProgressIndicator());
          },
        )));
  }

  Future<void> refreshView() => Future(() {
        setState(() {});
      });
}

class Expenditures extends StatefulWidget {
  const Expenditures({super.key});
  @override
  State<Expenditures> createState() => _ExpendituresState();
}
