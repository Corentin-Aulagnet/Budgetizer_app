import 'package:flutter/material.dart';
import 'package:budgetizer/charts.dart' as PieCharts;

class StatisticsView extends StatelessWidget {
  StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Statistics();
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
      Text(graphToDisplay,
          style: const TextStyle(
              color: Color(0xff000000),
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold)),
      GetChart(),
    ]));
  }

  Widget GetChart() {
    switch (graphToDisplay) {
      case 'Category Pie - Monthly':
        return PieCharts.CategoryPie(pieType: PieCharts.PieType.monthly);

      case 'Category Pie - Yearly':
        return PieCharts.CategoryPie(pieType: PieCharts.PieType.yearly);

      case 'Category Bar':
        return PieCharts.CategoryPie(pieType: PieCharts.PieType.monthly);
    }
    throw ErrorWidget(const Text("No valid chart selected"));
  }
}

class Statistics extends StatefulWidget {
  const Statistics({super.key});
  @override
  State<Statistics> createState() => _StatisticsState();
}
