import 'dart:math';

import 'package:budgetizer/Categories/utils/category_utils.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:budgetizer/Expenses/utils/expenditure.dart';
import '../../app_colors.dart';
import 'indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetizer/Analytics/blocs/analytics_bloc.dart';

class YearlyPie extends StatefulWidget {
  double aspectRatio;
  Axis alignment;
  YearlyPie({super.key, this.aspectRatio = 1, this.alignment = Axis.vertical});
  @override
  State<StatefulWidget> createState() => YearlyPieState();
}

class MonthlyPie extends StatefulWidget {
  double aspectRatio;
  Axis alignment;
  MonthlyPie({super.key, this.aspectRatio = 1, this.alignment = Axis.vertical});
  @override
  State<StatefulWidget> createState() => MonthlyPieState();
}

class MontlhyBarChart extends StatelessWidget {
  late List<MonthDisplay> months;
  final double axisFontSize = 14;
  double maxY = 0.0;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BarChartBloc, BarChartState>(
      builder: (context, state) {
        months = state.dates;
        return Column(children: [
          Card(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: BarChart(BarChartData(
                      titlesData: xAxisTitlesData,
                      barGroups: getData(months),
                      gridData: FlGridData(drawVerticalLine: false))))),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: showingIndicators(context, months),
          ),
        ]);
      },
    );
  }

  List<Widget> showingIndicators(
      BuildContext context, List<MonthDisplay> monthsToDisplay) {
    Set<CategoryDescriptor> categoriesDisplayed = {};
    monthsToDisplay = bubbleSort(monthsToDisplay);
    for (MonthDisplay monthYear in monthsToDisplay) {
      Map<CategoryDescriptor, double> dataAggregate = getDataByMonth(monthYear);
      categoriesDisplayed.addAll(dataAggregate.keys);
    }

    return List.generate(categoriesDisplayed.length, (index) {
      return Column(children: <Widget>[
        Row(
          children: [
            Indicator(
              color: AppColors.palette3[index],
              text: List.from(categoriesDisplayed)
                  .elementAt(index)
                  .getName(context),
              isSquare: true,
            ),
            Text(List.from(categoriesDisplayed).elementAt(index).emoji)
          ],
        ),
        const SizedBox(
          height: 4,
        )
      ]);
    });
  }

  Widget getXAxisTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: axisFontSize,
    );
    String text = months[value.toInt()].toString();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: style,
      ),
    );
  }

  List<MonthDisplay> bubbleSort(List<MonthDisplay> list) {
    for (int i = 0; i < list.length; i++) {
      for (int j = 0; j < list.length - 1; j++) {
        if (list[j] > list[j + 1]) {
          MonthDisplay num = list[j];
          list[j] = list[j + 1];
          list[j + 1] = num;
        }
      }
    }
    return list;
  }

  Widget getYAxisTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: axisFontSize,
    );
    String text = value == 0.0 ? '' : value.toString();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: style,
      ),
    );
  }

  FlTitlesData get xAxisTitlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: months.isEmpty ? 0 : 30,
            getTitlesWidget: getXAxisTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getYAxisTitles,
            reservedSize:
                months.isEmpty ? 0 : (axisFontSize * maxY.toString().length),
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );
  List<BarChartGroupData> getData(List<MonthDisplay> monthsToDisplay) {
    maxY = 0;
    //aggregate data per categorie per months
    Map<String, Map<CategoryDescriptor, double>> data = {};
    Set<CategoryDescriptor> categories = {};
    Map<CategoryDescriptor, Color> categoryColor = {};
    monthsToDisplay = bubbleSort(monthsToDisplay);
    for (MonthDisplay monthYear in monthsToDisplay) {
      Map<CategoryDescriptor, double> dataAggregate = getDataByMonth(monthYear);
      categories.addAll(dataAggregate.keys);
      data[monthYear.toString()] = dataAggregate;
    }
    //Atribute a color for each categories that will be displayed
    for (int index = 0; index < List.from(categories).length; index++) {
      categoryColor[List.from(categories)[index]] = AppColors.palette3[index];
    }

    List<BarChartGroupData> groups = List.empty(growable: true);
    for (int monthIndex = 0; monthIndex < data.keys.length; monthIndex++) {
      //create one BarChartRodStackItem per category in a month
      List<BarChartRodData> rods = List.empty(growable: true);
      String monthYear = data.keys.elementAt(monthIndex);
      double nextFromValue = 0;
      Map<CategoryDescriptor, double> dataAggregate = data[monthYear]!;
      List<BarChartRodStackItem> monthRodStackItems =
          List.empty(growable: true);
      for (int catIndex = 0; catIndex < dataAggregate.keys.length; catIndex++) {
        //in a category
        CategoryDescriptor cat = dataAggregate.keys.elementAt(catIndex);
        double value = dataAggregate[cat]!;
        monthRodStackItems.add(BarChartRodStackItem(
            nextFromValue, nextFromValue + value, categoryColor[cat]!));
        nextFromValue += value;
      }
      maxY = max(maxY, nextFromValue);
      //create one BarChartRodData per month
      rods.add(BarChartRodData(
          toY: nextFromValue, rodStackItems: monthRodStackItems));
//create one BarChartGroupData per month
      groups.add(BarChartGroupData(x: monthIndex, barRods: rods));
    }
    return groups;
  }

  Map<CategoryDescriptor, double> getDataByMonth(MonthDisplay monthYear) {
    List<Expenditure> results = DatabaseHandler.expendituresList;
    List<Expenditure> dataToPlot = List.empty(growable: true);
    Set<CategoryDescriptor> categoriesToPlot = {};
    Map<CategoryDescriptor, double> dataToPlotGroupedBycategories = {};
    //Filters by date
    DateTime mmyy = DateTime(monthYear.y, monthYear.m);
    for (Expenditure element in results) {
      DateTime date = element.date;
      bool categoryIsARoot = element.category.parent == null;
      if (date.month == mmyy.month &&
          date.year == mmyy.year &&
          categoryIsARoot) {
        //Show only cluster or orphan category (ie. that have no parents)
        categoriesToPlot.add(element.category);
        dataToPlot.add(element);
      }
    }
    //Aggregate by categories
    for (CategoryDescriptor element in categoriesToPlot) {
      dataToPlotGroupedBycategories[element] = 0;
    }
    for (int i = 0; i < dataToPlot.length; i++) {
      Expenditure element = dataToPlot[i];
      dataToPlotGroupedBycategories.update(
        element.category,
        (value) => element.value + value,
        ifAbsent: () => element.value,
      );
    }
    return dataToPlotGroupedBycategories;
  }
}

enum ChartsType { monthlyPie, yearlyPie, barChart }

List<Color> colors = <Color>[
  const Color(0xff0293ee),
  const Color(0xfff8b250),
  const Color(0xff845bef),
  const Color(0xff13d38e),
];

class YearlyPieState extends State<YearlyPie> {
  int touchedIndex = -1;
  late ChartsType type;
  DateTime yy = DateTime(2021);
  bool displayAllCategories = false;
  String yearOnGraph =
      DatabaseHandler.expendituresList.first.date.year.toString();

  double totalValueDisplayed = 0.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PieChartBloc, PieChartState>(builder: (_, chartState) {
      type = chartState.chartType;
      yearOnGraph = chartState.year.first.toString();
      displayAllCategories = chartState.showAllCategories;
      return Card(
          color: Colors.white,
          child: Flex(
            direction: widget.alignment,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: widget.aspectRatio,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 80,
                      sections: showingSections(),
                    ),
                  ),
                ),
              ),
              Wrap(
                direction: flipAxis(widget.alignment),
                spacing: 8.0, // Adjust as needed
                runSpacing: 8.0, // Adjust as needed
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: showingIndicators(),
              )
            ],
          ));
    });
  }

  List<Widget> showingIndicators() {
    Map<CategoryDescriptor, double> data = getData();
    return List.generate(data.length, (index) {
      return Column(children: <Widget>[
        Row(
          children: [
            Indicator(
              color: AppColors.palette3[index],
              text: data.keys.elementAt(index).getName(context),
              isSquare: true,
            ),
            Text(data.keys.elementAt(index).emoji)
          ],
        ),
        const SizedBox(
          height: 4,
        )
      ]);
    });
  }

  List<PieChartSectionData> showingSections() {
    Map<CategoryDescriptor, double> data = getData();
    return List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 10.0;
      final radius = isTouched ? 60.0 : 50.0;
      return PieChartSectionData(
          color: AppColors.palette3[i],
          value: data.values.elementAt(i),
          title: data.keys.elementAt(i).getName(context),
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
          badgeWidget: isTouched
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${(data.values.elementAt(i) * totalValueDisplayed / 100).toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                )
              : null,
          badgePositionPercentageOffset: 1);
    });
  }

  Map<CategoryDescriptor, double> getData() {
    List<Expenditure> results = DatabaseHandler.expendituresList;
    List<Expenditure> dataToPlot = List.empty(growable: true);
    Set<CategoryDescriptor> categoriesToPlot = {};
    Map<CategoryDescriptor, double> dataToPlotGroupedBycategories = {};
    totalValueDisplayed = 0.0;
    //Filters by date
    yy = DateTime(int.parse(yearOnGraph));
    for (Expenditure exp in results) {
      DateTime date = exp.date;
      bool categoryIsARoot = exp.category.parent == null;
      if (date.year == yy.year && (displayAllCategories || categoryIsARoot)) {
        categoriesToPlot.add(exp.category);
        dataToPlot.add(exp);
      } else if (date.year == yy.year &&
          !(displayAllCategories || categoryIsARoot)) {
        dataToPlot.add(Expenditure(
            title: exp.title,
            category: exp.category.parent!,
            value: exp.value,
            date: date,
            dataBaseId: exp.dataBaseId));
      }
      //Aggregate by categories
      for (CategoryDescriptor cat in categoriesToPlot) {
        dataToPlotGroupedBycategories[cat] = 0;
      }
      for (int i = 0; i < dataToPlot.length; i++) {
        Expenditure exp = dataToPlot[i];
        totalValueDisplayed += exp.value;
        dataToPlotGroupedBycategories.update(
          exp.category,
          (value) => exp.value + value,
          ifAbsent: () => exp.value,
        );
      }
      //Normalize and converts to %
      for (var element in dataToPlotGroupedBycategories.keys) {
        double tmpValue = dataToPlotGroupedBycategories[element]!;
        tmpValue /= totalValueDisplayed;
        tmpValue *= 100;
        dataToPlotGroupedBycategories[element] = tmpValue;
      }
    }
    return dataToPlotGroupedBycategories;
  }

  List<Widget> showingListTiles() {
    Map<CategoryDescriptor, double> data = getData();
    return List.generate(data.length, (index) {
      return ListTile(
          leading: Text(data.keys.elementAt(index).emoji),
          title: Text(data.keys.elementAt(index).getName(context)),
          trailing: Text(
              '${(data.values.elementAt(index) * totalValueDisplayed / 100).toStringAsFixed(2)}€'));
    });
  }
}

class MonthlyPieState extends State<MonthlyPie> {
  int touchedIndex = -1;
  late ChartsType type;
  DateTime mmyy = DateTime(2021, 12);

  String monthOnGraph =
      DatabaseHandler.expendituresList.first.date.month.toString();
  String yearOnGraph =
      DatabaseHandler.expendituresList.first.date.year.toString();

  double totalValueDisplayed = 0.0;
  bool displayAllCategories = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PieChartBloc, PieChartState>(builder: (_, chartState) {
      type = chartState.chartType;
      monthOnGraph = chartState.month.first.toString();
      yearOnGraph = chartState.year.first.toString();
      displayAllCategories = chartState.showAllCategories;
      bool isThereData = getData().isNotEmpty;
      if (isThereData) {
        return Card(
            color: Colors.white,
            child: Flex(
              direction: widget.alignment,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: widget.aspectRatio,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 0,
                        centerSpaceRadius: 80,
                        sections: showingSections(),
                      ),
                    ),
                  ),
                ),
                Wrap(
                  direction: flipAxis(widget.alignment),
                  spacing: 8.0, // Adjust as needed
                  runSpacing: 8.0, // Adjust as needed
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: showingIndicators(),
                )
              ],
            ));
      } else {
        return Card(
            color: Colors.white,
            child: Text(
                "Oups no data to display, right now")); //TODO Localization //TODO add an cartoon image
      }
    });
  }

  List<Widget> showingIndicators() {
    Map<CategoryDescriptor, double> data = getData();
    return List.generate(data.length, (index) {
      return Column(children: <Widget>[
        Row(
          children: [
            Indicator(
              color: AppColors.palette3[index],
              text: data.keys.elementAt(index).getName(context),
              isSquare: true,
            ),
            Text(data.keys.elementAt(index).emoji)
          ],
        ),
        const SizedBox(
          height: 4,
        )
      ]);
    });
  }

  List<PieChartSectionData> showingSections() {
    Map<CategoryDescriptor, double> data = getData();
    return List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 10.0;
      final radius = isTouched ? 60.0 : 50.0;
      return PieChartSectionData(
          color: AppColors.palette3[i],
          value: data.values.elementAt(i),
          title: data.keys.elementAt(i).getName(context),
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
          badgeWidget: isTouched
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${(data.values.elementAt(i) * totalValueDisplayed / 100).toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                )
              : null,
          badgePositionPercentageOffset: 1);
    });
  }

  Map<CategoryDescriptor, double> getData() {
    List<Expenditure> results = DatabaseHandler.expendituresList;
    List<Expenditure> dataToPlot = List.empty(growable: true);
    Set<CategoryDescriptor> categoriesToPlot = {};
    Map<CategoryDescriptor, double> dataToPlotGroupedBycategories = {};
    totalValueDisplayed = 0.0;
    //Filters by date
    mmyy = DateTime(int.parse(yearOnGraph), int.parse(monthOnGraph));
    for (Expenditure exp in results) {
      DateTime date = exp.date;
      bool categoryIsARoot = exp.category.parent == null;
      if (date.month == mmyy.month &&
          date.year == mmyy.year &&
          (displayAllCategories || categoryIsARoot)) {
        categoriesToPlot.add(exp.category);
        dataToPlot.add(exp);
      } else if (date.month == mmyy.month &&
          date.year == mmyy.year &&
          !(displayAllCategories || categoryIsARoot)) {
        dataToPlot.add(Expenditure(
            title: exp.title,
            category: exp.category.parent!,
            value: exp.value,
            date: date,
            dataBaseId: exp.dataBaseId));
      }
    }
    //Aggregate by categories
    for (var element in categoriesToPlot) {
      dataToPlotGroupedBycategories[element] = 0;
    }
    for (int i = 0; i < dataToPlot.length; i++) {
      Expenditure element = dataToPlot[i];
      totalValueDisplayed += element.value;
      dataToPlotGroupedBycategories.update(
        element.category,
        (value) => element.value + value,
        ifAbsent: () => element.value,
      );
    }
    //Normalize and converts to %
    for (var element in dataToPlotGroupedBycategories.keys) {
      double tmpValue = dataToPlotGroupedBycategories[element]!;
      tmpValue /= totalValueDisplayed;
      tmpValue *= 100;
      dataToPlotGroupedBycategories[element] = tmpValue;
    }
    return dataToPlotGroupedBycategories;
  }

  List<Widget> showingListTiles() {
    Map<CategoryDescriptor, double> data = getData();
    return List.generate(data.length, (index) {
      return ListTile(
          leading: Text(data.keys.elementAt(index).emoji),
          title: Text(data.keys.elementAt(index).getName(context)),
          trailing: Text(
              '${(data.values.elementAt(index) * totalValueDisplayed / 100).toStringAsFixed(2)}€'));
    });
  }
}

class PieSectionData {
  double value;
  String title;
  PieSectionData({required this.value, required this.title});
}
