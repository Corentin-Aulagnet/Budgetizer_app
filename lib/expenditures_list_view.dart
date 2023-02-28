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
            body: FutureBuilder<List<Expenditure>>(
          future: DatabaseHandler.fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  Expenditure row =
                      snapshot.data?[index] ?? Expenditure.error();
                  return ListTile(
                    title: Text('${row.title} | ${row.category.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(row.category.emoji),
                    subtitle: Text(
                        '${DateFormat.yMd('fr_Fr').format(row.date)} ${row.value.toString()}€'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ExpenditureView(expenditure: row)),
                      ).then((_) => setState(() {}));
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
