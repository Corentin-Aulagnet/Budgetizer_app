import 'package:ledgerstats/Expenses/view/add_expenditure_view.dart';
import 'package:ledgerstats/database_handler.dart';
import 'package:ledgerstats/Expenses/utils/expenditure.dart';
import 'package:flutter/material.dart';
import 'package:ledgerstats/Analytics/utils/charts.dart' as charts;
import 'package:ledgerstats/Analytics/blocs/analytics_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:multiple_search_selection/multiple_search_selection.dart';

import '../../app_colors.dart';
import '../../navigation_drawer.dart';

class StatisticsView extends StatelessWidget {
  StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (DatabaseHandler.expendituresList.isNotEmpty) {
      //TODO implement a FutureBuilder here to check if there are any data
      //Maybe we don't event need it and we just have to personnalize the messages from the Builder of Statistics
      return Statistics();
    } else {
      return const EmptyDataBaseStatistics();
    }
  }
}

class ChartsTabBar extends StatelessWidget {
  TabController tabController;
  ChartsTabBar({required this.tabController});
  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      tabs: [
        Tab(
            icon: Icon(
          IcoFontIcons.chartPieAlt,
          color: AppColors.primaryColor,
        )),
        Tab(
            icon: Icon(IcoFontIcons.chartBarGraph,
                color: AppColors.primaryColor)),
      ],
    );
  }
}

class Statistics extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StatisticsState();
}

class StatisticsState extends State<Statistics>
    with SingleTickerProviderStateMixin {
  Future<Data> _dataFuture = DatabaseHandler().getData();
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: TabBar(
          controller: tabController,
          tabs: const [
            Tab(
                icon: Icon(
              IcoFontIcons.chartPieAlt,
              color: AppColors.primaryColor,
            )),
            Tab(
                icon: Icon(IcoFontIcons.chartBarGraph,
                    color: AppColors.primaryColor)),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //We need a bloc for the expenditureList view to refresh only this widget after a expenditure has been added
            // Add your onPressed code here!
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddExpenditureView()));
          },
          backgroundColor: AppColors.secondaryColor,
          child: const Icon(Icons.add),
        ),
        drawer: AppNavigationDrawer(),
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.welcomeMessage),
        ),
        body: FutureBuilder<Data>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child:CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return TabBarView(controller: tabController, children: [
                //Tab 1
                BlocProvider(
                    create: (_) {
                      bool initialShowAllCategories = false;
                      String month =
                          snapshot.data!.expenses.first.date.month.toString();
                      String year =
                          snapshot.data!.expenses.first.date.year.toString();
                      return PieChartBloc(
                          data: snapshot.data!,
                          month: month,
                          year: year,
                          showAllCategories: initialShowAllCategories);
                    },
                    child: Column(
                        children: <Widget>[
                          PieTypeChips(),
                          Row(children: <Widget>[
                            const SizedBox(
                              width: 28,
                            ),
                            DateDropDownMenu(),
                            categoriesToDisplaySwitch(),
                          ]),
                          SelectedPie(),
                          //Expanded(child: SelectedPie()),
                        ])),
                //Tab 2
                BlocProvider(
                  create: (_) => BarChartBloc(data: snapshot.data!),
                  child: SingleChildScrollView(
                      child: Column(children: [
                    const SizedBox(
                      width: 10,
                    ),
                    charts.MontlhyBarChart(),
                    MonthsMultiSelector(snapshot.data!.expenses)
                  ])),
                )
              ]);
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
          },
        ));
  }
}

class categoriesToDisplaySwitch extends StatelessWidget {
  bool showAllCategories = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PieChartBloc, PieChartState>(
        builder: (context, chartState) {
      return Card(
          child: Row(children: [
        Text('Display all categories'), //TODO localization
        Switch(
            // This bool value toggles the switch.

            value: showAllCategories,
            activeColor: AppColors.primaryColor,
            onChanged: (bool value) {
              // This is called when the user toggles the switch.
              showAllCategories = value;
              BlocProvider.of<PieChartBloc>(context).add(
                  ChangePieChartCategoriesDisplayed(
                      showAllCategories: showAllCategories));
            })
      ]));
    });
  }
}

class MonthsMultiSelector extends StatelessWidget {
  List<Expenditure> expenses;
  MonthsMultiSelector(this.expenses);
  List<MonthDisplay> getSelectableMonths() {
    Set<MonthDisplay> datesSet = {};
    for (Expenditure exp in expenses) {
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
        searchField: const TextField(),
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
                BlocProvider.of<PieChartBloc>(context).add(ChangePieChartType(
                    chartType: charts.ChartsType.monthlyPie));
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
                BlocProvider.of<PieChartBloc>(context).add(
                    ChangePieChartType(chartType: charts.ChartsType.yearlyPie));
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
      return Card(
          child: Row(children: showingDateDropDownButton(chartState, context)));
    });
  }

  List<Widget> showingDateDropDownButton(
      PieChartState chartState, BuildContext context) {
    if (chartState.chartType == charts.ChartsType.monthlyPie) {
      return <Widget>[
        DropdownButton<String>(
          value: chartState.month,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            BlocProvider.of<PieChartBloc>(context)
                .add(ChangePieChartDate(month: value!, year: chartState.year));
          },
          items: getMonths(context),
        ),
        DropdownButton<String>(
          value: chartState.year,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            BlocProvider.of<PieChartBloc>(context)
                .add(ChangePieChartDate(month: chartState.month, year: value!));
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
            BlocProvider.of<PieChartBloc>(context)
                .add(ChangePieChartDate(month: chartState.month, year: value!));
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
