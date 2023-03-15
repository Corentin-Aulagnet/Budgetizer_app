import 'package:flutter/material.dart';
import 'package:budgetizer/expenditure_view.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:budgetizer/expenditure.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:budgetizer/home.dart';

class _ExpendituresState extends State<Expenditures> {
  late Future<List<Expenditure>> _dataFuture = DatabaseHandler.fetchData();
  @override
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: refreshView,
        child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton:
                Home.addExpenditureFloatingActionButton(context),
            drawer: Home.appNavigationDrawer(context),
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.welcomeMessage),
            ),
            key: UniqueKey(),
            body: FutureBuilder<List<Expenditure>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      Expenditure row =
                          snapshot.data?[index] ?? Expenditure.error();
                      return ListTile(
                        title: Text(
                            '${row.title} | ${row.category.getName(context)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text(row.category.emoji),
                        subtitle: Text(
                            '${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(row.date)} ${row.value.toString()}€'),
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
  Expenditures({super.key});
  @override
  State<Expenditures> createState() => _ExpendituresState();
}
