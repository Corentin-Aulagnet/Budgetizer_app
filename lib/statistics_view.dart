import 'package:budgetizer/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:budgetizer/charts.dart' as pie_charts;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:budgetizer/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetizer/expenditure.dart';

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

//BLoC things
//events
class GraphEvent {
  const GraphEvent();
}

class changeChartType extends GraphEvent {
  final pie_charts.PieType chartType;
  const changeChartType(this.chartType);
  @override
  String toString() => 'changeChartType { type: $chartType }';
}

class changeChartDate extends GraphEvent {
  final String month;
  final String year;
  const changeChartDate(this.month, this.year);
  @override
  String toString() => 'changeChartDate { date: $month/$year }';
}

//states
abstract class ChartState {
  final pie_charts.PieType chartType;
  final String month;
  final String year;
  const ChartState(
      {required this.chartType, required this.month, required this.year});
}

class ChartChanged extends ChartState {
  final pie_charts.PieType chartType;
  final String month;
  final String year;
  const ChartChanged(
      {required this.chartType, required this.month, required this.year})
      : super(chartType: chartType, month: month, year: year);

  @override
  pie_charts.PieType get type => chartType;
  @override
  String toString() => 'chartChanged { type: $chartType, date: $month/$year }';
}

//Bloc
class ChartBloc extends Bloc<GraphEvent, ChartState> {
  ChartBloc()
      : super(ChartChanged(
            chartType: pie_charts.PieType.monthly,
            month: DatabaseHandler.expendituresList.first.date.month.toString(),
            year:
                DatabaseHandler.expendituresList.first.date.year.toString())) {
    List<Expenditure> results = DatabaseHandler.expendituresList;
    for (var element in results) {
      DateTime date = element.date;
      months.add(date.month.toString());
      years.add(date.year.toString());
    }
    month = months.first;
    year = years.first;
    on<changeChartDate>(onDateChanged);
    on<changeChartType>(onTypeChanged);
  }
  ChartBloc.unique(
      {required this.chartType, required this.month, required this.year})
      : super(ChartChanged(chartType: chartType, month: month, year: year)) {
    List<Expenditure> results = DatabaseHandler.expendituresList;
    for (var element in results) {
      DateTime date = element.date;
      months.add(date.month.toString());
      years.add(date.year.toString());
    }
    on<changeChartDate>(onDateChanged);
    on<changeChartType>(onTypeChanged);
  }
  pie_charts.PieType chartType = pie_charts.PieType.monthly;
  late String month;
  late String year;
  Set<String> months = {};
  Set<String> years = {};

  void onDateChanged(changeChartDate event, Emitter<ChartState> emit) {
    month = event.month;
    year = event.year;
    emit(ChartChanged(
        chartType: chartType, month: event.month, year: event.year));
  }

  void onTypeChanged(changeChartType event, Emitter<ChartState> emit) {
    chartType = event.chartType;
    emit(ChartChanged(chartType: event.chartType, month: month, year: year));
  }
}

class Statistics extends StatelessWidget {
  pie_charts.PieType chartType = pie_charts.PieType.monthly;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => ChartBloc(),
        child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton:
                Home.addExpenditureFloatingActionButton(context),
            drawer: Home.appNavigationDrawer(context),
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.welcomeMessage),
            ),
            body: Column(children: <Widget>[
              TypeDropDownMenu(),
              Row(children: <Widget>[
                const SizedBox(
                  width: 28,
                ),
                DateDropDownMenu(),
              ]),
              pie_charts.CategoryPie(),
            ])));
  }
}

class TypeDropDownMenu extends StatelessWidget {
  List<pie_charts.PieType> choices = pie_charts.PieType.values;
  @override
  Widget build(context) {
    return BlocBuilder<ChartBloc, ChartState>(builder: (context, chartState) {
      return DropdownButton<pie_charts.PieType>(
        value: chartState.chartType,
        onChanged: (pie_charts.PieType? value) {
          // This is called when the user selects an item.
          BlocProvider.of<ChartBloc>(context).add(changeChartType(value!));
        },
        items: choices.map<DropdownMenuItem<pie_charts.PieType>>(
            (pie_charts.PieType value) {
          return DropdownMenuItem<pie_charts.PieType>(
              value: value,
              child: Text(
                value.toString(),
              )); //Displays a dropdown menu to select the type of chart
        }).toList(),
      );
    });
  }
}

class DateDropDownMenu extends StatelessWidget {
  Map<String, String> int2TextMonths = {
    //TODO localization
    '1': 'jan',
    '2': 'feb',
    '3': 'mar',
    '4': 'apr',
    '5': 'may',
    '6': 'jun',
    '7': 'jul',
    '8': 'aug',
    '9': 'sep',
    '10': 'oct',
    '11': 'nov',
    '12': 'dec'
  };
  @override
  Widget build(context) {
    return BlocBuilder<ChartBloc, ChartState>(builder: (context, chartState) {
      return Row(children: showingDateDropDownButton(chartState, context));
    });
  }

  List<Widget> showingDateDropDownButton(
      ChartState chartState, BuildContext context) {
    if (chartState.chartType == pie_charts.PieType.monthly) {
      return <Widget>[
        DropdownButton<String>(
          value: chartState.month,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            BlocProvider.of<ChartBloc>(context)
                .add(changeChartDate(value!, chartState.year));
          },
          items: getMonths(context),
        ),
        DropdownButton<String>(
          value: chartState.year,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            BlocProvider.of<ChartBloc>(context)
                .add(changeChartDate(chartState.month, value!));
          },
          items: getYears(context),
        ),
      ];
    } else {
      return <Widget>[
        DropdownButton<String>(
          value: chartState.year,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            BlocProvider.of<ChartBloc>(context)
                .add(changeChartDate(chartState.month, value!));
          },
          items: getYears(context),
        ),
      ];
    }
  }

  List<DropdownMenuItem<String>> getMonths(BuildContext context) {
    Set<String> months = BlocProvider.of<ChartBloc>(context).months;
    return List.generate(months.length, (index) {
      return DropdownMenuItem<String>(
          value: months.elementAt(index),
          child: Text(
            int2TextMonths[months.elementAt(index)]!,
          ));
    });
  }

  List<DropdownMenuItem<String>> getYears(BuildContext context) {
    Set<String> years = BlocProvider.of<ChartBloc>(context).years;
    return List.generate(years.length, (index) {
      return DropdownMenuItem<String>(
          value: years.elementAt(index),
          child: Text(
            years.elementAt(index),
          ));
    });
  }
}

/*class Statistics extends StatefulWidget {
  const Statistics({super.key});
  @override
  State<Statistics> createState() => _StatisticsState();
}*/

class EmptyDataBaseStatistics extends StatelessWidget {
  const EmptyDataBaseStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text(
          "Nothing to display\n Please add an expenditure in the list"), //TODO localization //TODO polish
    );
  }
}
