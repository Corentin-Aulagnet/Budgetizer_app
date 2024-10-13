import 'dart:math';

import 'package:ledgerstats/Categories/utils/category_utils.dart';
import 'package:ledgerstats/database_handler.dart';
import 'package:ledgerstats/Expenses/utils/expenditure.dart';
import 'package:ledgerstats/app_colors.dart';
import 'package:ledgerstats/Analytics/utils/indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ledgerstats/Analytics/blocs/analytics_bloc.dart';
import 'package:ledgerstats/tuple.dart';

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
                      barGroups: getBarChartGroupData(months, state),
                      gridData: FlGridData(drawVerticalLine: false))))),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: showingIndicators(context, state),
          ),
        ]);
      },
    );
  }

  List<Widget> showingIndicators(BuildContext context, BarChartState state) {
    Tuple<Map<String, Map<CategoryDescriptor, double>>, Set<CategoryDescriptor>>
        tuple = state.groupedData;
    Set<CategoryDescriptor> categoriesDisplayed = tuple.second;

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
  List<BarChartGroupData> getBarChartGroupData(
      List<MonthDisplay> monthsToDisplay, BarChartState state) {
    maxY = 0;
    //aggregate data per categorie per months

    Tuple<Map<String, Map<CategoryDescriptor, double>>, Set<CategoryDescriptor>>
        tuple = state.groupedData;
    Map<String, Map<CategoryDescriptor, double>> data = tuple.first;
    Set<CategoryDescriptor> categories = tuple.second;
    Map<CategoryDescriptor, Color> categoryColor = {};

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

  double totalValueDisplayed = 0.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PieChartBloc, PieChartState>(builder: (_, chartState) {
      type = chartState.chartType;
      displayAllCategories = chartState.showAllCategories;

      List<Expenditure> dataToDisplay = chartState.data.expenses
          .where((element) =>
              element.date.isAfter(DateTime(int.parse(chartState.year))))
          .toList();
      bool isThereData = dataToDisplay.isNotEmpty;
      if (isThereData) {
        totalValueDisplayed = 0.0;
        for (Expenditure exp in dataToDisplay) {
          totalValueDisplayed = totalValueDisplayed + exp.value;
        }
      }
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
                      sections: showingSections(chartState),
                    ),
                  ),
                ),
              ),
              Wrap(
                direction: flipAxis(widget.alignment),
                spacing: 8.0, // Adjust as needed
                runSpacing: 8.0, // Adjust as needed
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: showingIndicators(chartState),
              )
            ],
          ));
    });
  }

  List<Widget> showingIndicators(PieChartState state) {
    PieChartDataTuple data = state.groupedData;
    print(data);
    return List.generate(data.map.length, (index) {
      return Column(children: <Widget>[
        Row(
          children: [
            Indicator(
              color: AppColors.palette3[index],
              text: data.map.keys.elementAt(index).getName(context),
              isSquare: true,
            ),
            Text(data.map.keys.elementAt(index).emoji)
          ],
        ),
        const SizedBox(
          height: 4,
        )
      ]);
    });
  }

  List<PieChartSectionData> showingSections(PieChartState state) {
    PieChartDataTuple data = state.groupedData;
    return List.generate(data.map.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 10.0;
      final radius = isTouched ? 60.0 : 50.0;
      return PieChartSectionData(
          color: AppColors.palette3[i],
          value: data.map.values.elementAt(i),
          title: data.map.keys.elementAt(i).getName(context),
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
                    '${(data.map.values.elementAt(i) * totalValueDisplayed / 100).toStringAsFixed(2)}€',
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

  List<Widget> showingListTiles(PieChartState state) {
    PieChartDataTuple data = state.groupedData;
    return List.generate(data.map.length, (index) {
      return ListTile(
          leading: Text(data.map.keys.elementAt(index).emoji),
          title: Text(data.map.keys.elementAt(index).getName(context)),
          trailing:
              Text('${(data.map.values.elementAt(index)).toStringAsFixed(2)}€'));
    });
  }
}

class MonthlyPieState extends State<MonthlyPie> {
  int touchedIndex = -1;
  late ChartsType type;
  DateTime mmyy = DateTime(2021, 12);
  double totalValueDisplayed = 0.0;
  bool displayAllCategories = false;

  @override
  Widget build(BuildContext context) {
    type = BlocProvider.of<PieChartBloc>(context).chartType;
    displayAllCategories =
        BlocProvider.of<PieChartBloc>(context).showAllCategories;
    PieChartDataTuple data = BlocProvider.of<PieChartBloc>(context)
        .getCategorizedDataByMonth();
    bool isThereData = data.map.isNotEmpty;
    if (isThereData) {
      return Column(
        children: [
          Text("Total value ${data.totalValue.toStringAsFixed(2)}€"),
          AspectRatio(
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
                  sections: showingSections(
                      data),
                ),
              )),
          SizedBox(
              height: 16 * 5,
              width: double.infinity,
              child: SingleChildScrollView(
                  child: showingIndicators(
                      data)))
        ],
      );
    } else {
      return const Card(
          color: Colors.white,
          child: Text(
              "Oups no data to display right now")); //TODO Localization //TODO add a cartoon image
    }
  }

  Widget showingIndicators(PieChartDataTuple data) {
    return /*ListView.builder(
        scrollDirection: Axis.vertical,
        //shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Row(children:[Indicator(
            color: AppColors.palette3[index],
            text: '${data.keys.elementAt(index).emoji} ${data.keys.elementAt(index).getName(context)}',
            isSquare: true,
          )])
          ;

        });*/
        Column(
            children: List.generate(data.map.length, (index) {
      return Indicator(
        color: AppColors.palette3[index],
        text:
            '${data.map.keys.elementAt(index).emoji} ${data.map.keys.elementAt(index).getName(context)}',
        isSquare: true,
      );
    }));
  }

  List<PieChartSectionData> showingSections(
      PieChartDataTuple data) {
    return List.generate(data.map.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 10.0;
      final radius = isTouched ? 60.0 : 50.0;
      return PieChartSectionData(
          color: AppColors.palette3[i],
          value: data.map.values.elementAt(i),
          title: data.map.keys.elementAt(i).getEmoji(context),
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
                    '${(data.map.values.elementAt(i) * data.totalValue / 100).toStringAsFixed(2)}€',
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

  List<Widget> showingListTiles(PieChartState state) {
    PieChartDataTuple data = state.groupedData;
    return List.generate(data.map.length, (index) {
      return ListTile(
          leading: Text(data.map.keys.elementAt(index).emoji),
          title: Text(data.map.keys.elementAt(index).getName(context)),
          trailing: Text(
              '${(data.map.values.elementAt(index) * totalValueDisplayed / 100).toStringAsFixed(2)}€'));
    });
  }
}

class PieSectionData {
  double value;
  String title;
  PieSectionData({required this.value, required this.title});
}
