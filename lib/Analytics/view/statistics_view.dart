import 'package:budgetizer/database_handler.dart';
import 'package:budgetizer/expenditure.dart';
import 'package:flutter/material.dart';
import 'package:budgetizer/charts.dart' as charts;
import 'package:budgetizer/Analytics/blocs/analytics_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:budgetizer/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';

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

class ChartsTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const TabBar(
      tabs: [
        Tab(
            icon: Icon(
          IcoFontIcons.chartPieAlt,
          color: primaryColor,
        )),
        Tab(icon: Icon(IcoFontIcons.chartBarGraph, color: primaryColor)),
      ],
    );
  }
}

class Statistics extends StatelessWidget {
  charts.ChartsType chartType = charts.ChartsType.monthlyPie;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: ChartsTabBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Home.addExpenditureFloatingActionButton(context),
        drawer: Home.appNavigationDrawer(context),
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.welcomeMessage),
        ),
        body: TabBarView(children: [
          BlocProvider(
              create: (_) => PieChartBloc(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    PieTypeChips(),
                    Row(children: <Widget>[
                      const SizedBox(
                        width: 28,
                      ),
                      DateDropDownMenu(),
                    ]),
                    SelectedPie(),
                  ])),
          BlocProvider(
            create: (_) => BarChartBloc(),
            child: SingleChildScrollView(
                child: Column(children: [
              const SizedBox(
                width: 10,
              ),
              charts.MontlhyBarChart(),
              MonthsMultiSelector()
            ])),
          )
        ]),
      ),
    );
  }
}

class MonthsMultiSelector extends StatelessWidget {
  List<MonthDisplay> getSelectableMonths() {
    List<Expenditure> exps = DatabaseHandler.expendituresList;
    Set<MonthDisplay> datesSet = {};
    for (Expenditure exp in exps) {
      MonthDisplay monthDisplay =
          MonthDisplay(m: exp.date.month, y: exp.date.year);
      datesSet.add(monthDisplay);
    }
    return datesSet.toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BarChartBloc, BarChartState>(builder: (context, state) {
      List<MonthDisplay> selectableMonths = getSelectableMonths();
      selectableMonths.removeWhere((element) => state.dates.contains(element));
      List<MonthDisplay> selectedMonths = List.from(state.dates);
      return MultipleSearchSelection<MonthDisplay>(
        items: selectableMonths,
        initialPickedItems: state.dates,
        onItemAdded: (item) {
          selectedMonths.add(item);
          BlocProvider.of<BarChartBloc>(context)
              .add(DatesAddedEvent(dates: [item]));
        },
        onItemRemoved: (item) {
          selectedMonths.remove(item);
          BlocProvider.of<BarChartBloc>(context)
              .add(DatesRemovedEvent(dates: [item]));
        },
        onTapSelectAll: () {
          selectedMonths = selectableMonths;

          BlocProvider.of<BarChartBloc>(context)
              .add(DatesAddedEvent(dates: selectableMonths));
          selectableMonths = List.empty(growable: true);
        },
        onTapClearAll: () {
          selectableMonths = selectedMonths;
          BlocProvider.of<BarChartBloc>(context)
              .add(DatesRemovedEvent(dates: selectedMonths));
          selectedMonths = List.empty(growable: true);
        },
        itemBuilder: (MonthDisplay monthYear, int i) {
          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 12,
                ),
                child: Text(monthYear.toString()),
              ),
            ),
          );
        },
        fieldToCheck: (c) {
          return c.toString(); // String
        },
        pickedItemBuilder: (monthYear) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(monthYear.toString()),
            ),
          );
        },
      );
    });
  }
}

class SelectedPie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PieChartBloc, PieChartState>(
      builder: (_, chartState) =>
          chartState.chartType == charts.ChartsType.monthlyPie
              ? charts.MonthlyPie()
              : charts.YearlyPie(),
    );
  }
}

class PieTypeChips extends StatelessWidget {
  charts.ChartsType? type = charts.ChartsType.monthlyPie;
  @override
  Widget build(context) {
    return BlocBuilder<PieChartBloc, PieChartState>(
        builder: (context, chartState) {
      return Row(
        children: <Widget>[
          ChoiceChip(
            label: const Text('Monthly'), //TODO localizations
            selected: type == charts.ChartsType.monthlyPie,
            onSelected: (bool selected) {
              if (selected) {
                BlocProvider.of<PieChartBloc>(context).add(
                    const ChangePieChartType(charts.ChartsType.monthlyPie));
                type = charts.ChartsType.monthlyPie;
              } else {
                type = null;
              }
            },
          ),
          ChoiceChip(
            label: const Text('Yearly'), //TODO localizations
            selected: type == charts.ChartsType.yearlyPie,
            onSelected: (bool selected) {
              if (selected) {
                BlocProvider.of<PieChartBloc>(context)
                    .add(const ChangePieChartType(charts.ChartsType.yearlyPie));
                type = charts.ChartsType.yearlyPie;
              } else {
                type = null;
              }
            },
          )
        ],
      );
    });
  }
}

class DateDropDownMenu extends StatelessWidget {
  @override
  Widget build(context) {
    return BlocBuilder<PieChartBloc, PieChartState>(
        builder: (context, chartState) {
      return Row(children: showingDateDropDownButton(chartState, context));
    });
  }

  List<Widget> showingDateDropDownButton(
      PieChartState chartState, BuildContext context) {
    if (chartState.chartType == charts.ChartsType.monthlyPie) {
      return <Widget>[
        DropdownButton<String>(
          value: chartState.month.first,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            BlocProvider.of<PieChartBloc>(context)
                .add(ChangePieChartDate([value!], chartState.year));
          },
          items: getMonths(context),
        ),
        DropdownButton<String>(
          value: chartState.year.first,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            BlocProvider.of<PieChartBloc>(context)
                .add(ChangePieChartDate(chartState.month, [value!]));
          },
          items: getYears(context),
        ),
      ];
    } else {
      return <Widget>[
        DropdownButton<String>(
          value: chartState.year.first,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            BlocProvider.of<PieChartBloc>(context)
                .add(ChangePieChartDate(chartState.month, [value!]));
          },
          items: getYears(context),
        ),
      ];
    }
  }

  List<DropdownMenuItem<String>> getMonths(BuildContext context) {
    Set<String> months = BlocProvider.of<PieChartBloc>(context).months;
    return List.generate(months.length, (index) {
      return DropdownMenuItem<String>(
          value: months.elementAt(index),
          child: Text(
            MonthDisplay.intToStrMonths[int.parse(months.elementAt(index))]!,
          ));
    });
  }

  List<DropdownMenuItem<String>> getYears(BuildContext context) {
    Set<String> years = BlocProvider.of<PieChartBloc>(context).years;
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