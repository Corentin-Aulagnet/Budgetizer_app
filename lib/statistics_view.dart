import 'package:budgetizer/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:budgetizer/charts.dart' as pie_charts;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:budgetizer/home.dart';

class StatisticsView extends StatelessWidget {
  StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (DatabaseHandler.expendituresList.isNotEmpty) {
      return Statistics();
    } else {
      return const EmptyDataBaseStatistics();
    }
  }
}

class _StatisticsState extends State<Statistics> {
  List<String> choices = [
    'Category Pie - Monthly',
    'Category Pie - Yearly',
    'Category Bar',
  ];
  String graphToDisplay = 'Category Pie - Monthly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Home.addExpenditureFloatingActionButton(context),
        drawer: Home.appNavigationDrawer(context),
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.welcomeMessage),
        ),
        body: Column(children: <Widget>[
          DropdownButton<String>(
            value: graphToDisplay,
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                Scaffold.of(context).setState(() {});
                graphToDisplay = value!; //Code to run
              });
            },
            items: choices.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                  ));
            }).toList(),
          ),
          getChart(),
        ]));
  }

  Widget getChart() {
    switch (graphToDisplay) {
      case 'Category Pie - Monthly':
        return pie_charts.CategoryPie(pieType: pie_charts.PieType.monthly);

      case 'Category Pie - Yearly':
        return pie_charts.CategoryPie(pieType: pie_charts.PieType.yearly);

      case 'Category Bar':
        return pie_charts.CategoryPie(pieType: pie_charts.PieType.monthly);
    }
    throw ErrorWidget(const Text("No valid chart selected"));
  }
}

class Statistics extends StatefulWidget {
  const Statistics({super.key});
  @override
  State<Statistics> createState() => _StatisticsState();
}

class EmptyDataBaseStatistics extends StatelessWidget {
  const EmptyDataBaseStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("Nothing to display\n Please add an expenditure in the list"),
    );
  }
}
