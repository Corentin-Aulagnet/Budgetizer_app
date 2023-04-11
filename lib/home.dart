import 'dart:math';
import 'package:ledgerstats/Analytics/utils/charts.dart';
import 'package:ledgerstats/Analytics/blocs/analytics_bloc.dart';
import 'package:ledgerstats/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ledgerstats/Expenses/view/add_expenditure_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:ledgerstats/app_colors.dart';
import 'package:ledgerstats/navigation_drawer.dart';

class AddExpenditureFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        //We need a bloc for the expenditureList view to refresh only this widget after a expenditure has been added
        // Add your onPressed code here!
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddExpenditureView()));
      },
      backgroundColor: AppColors.secondaryColor,
      child: const Icon(Icons.add),
    );
  }
}

class Home extends StatefulWidget {
  Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<Data> _dataFuture = DatabaseHandler().getData();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Data>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            if (snapshot.data!.expenses.isNotEmpty) {
              return BlocProvider(
                  create: (_) => PieChartBloc.unique(
                      data: snapshot.data!,
                      showAllCategories: false,
                      chartType: ChartsType.monthlyPie,
                      month: DateTime.now().month.toString(),
                      year: DateTime.now().year.toString()),
                  child: Scaffold(
                      drawer: AppNavigationDrawer(),
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.endFloat,
                      appBar: AppBar(
                        title:
                            Text(AppLocalizations.of(context)!.welcomeMessage),
                      ),
                      floatingActionButton: FloatingActionButton(
                        onPressed: () {
                          //We need a bloc for the expenditureList view to refresh only this widget after a expenditure has been added
                          // Add your onPressed code here!
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddExpenditureView())).then((_) =>
                              setState(() {})); //TODO Add a Bloc for expenses
                        },
                        backgroundColor: AppColors.secondaryColor,
                        child: const Icon(Icons.add),
                      ),
                      body: Column(
                        children: [
                          Center(
                              child: Text(
                            AppLocalizations.of(context)!
                                .welcomeUser("Test User"), //TODO localization
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          )),
                          Center(
                              child: Text(
                            AppLocalizations.of(context)!.monthPreview(
                                DateTime.now()), //TODO localization
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          )),
                          MonthlyPie(
                            alignment: Axis.horizontal,
                          ),
                          ListView.builder(
                            itemCount: min(snapshot.data!.expenses.length, 2),
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Text(snapshot
                                    .data!.expenses[index].category.emoji),
                                title: Text(
                                    '${snapshot.data!.expenses[index].title} | ${snapshot.data!.expenses[index].category.getName(context)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(snapshot.data!.expenses[index].date)} ${snapshot.data!.expenses[index].value.toString()}€'),
                              );
                            },
                          )
                        ],
                      )));
            } else {
              return Scaffold(
                drawer: AppNavigationDrawer(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)!.welcomeMessage),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddExpenditureView())).then(
                        (_) => setState(() {})); //TODO Add a Bloc for expenses
                  },
                  backgroundColor: AppColors.secondaryColor,
                  child: const Icon(Icons.add),
                ),
                body: null,
              );
            }
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return Column(children: <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              ),
            ]);
          } else {
            return Column(children: <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: No Data'),
              ),
            ]);
          }
        });
  }
}
