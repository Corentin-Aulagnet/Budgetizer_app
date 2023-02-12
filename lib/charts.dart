import 'package:budgetizer/database_handler.dart';
import 'package:budgetizer/expenditure.dart';
import 'package:budgetizer/indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPie extends StatefulWidget {
  late PieType pieType;
  CategoryPie({super.key, required this.pieType});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

enum PieType { monthly, yearly }

List<Color> colors = <Color>[
  const Color(0xff0293ee),
  const Color(0xfff8b250),
  const Color(0xff845bef),
  const Color(0xff13d38e),
];

class PieChart2State extends State<CategoryPie> {
  int touchedIndex = -1;
  late PieType type = widget.pieType;
  DateTime mmyy = DateTime(2021, 12);

  double totalValueDisplayed = 0.0;

  @override
  Widget build(BuildContext context) {
    type = widget.pieType;
    return Card(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
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
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: showingIndicators(),
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<Widget> showingIndicators() {
    Map<String, double> data = GetData();
    return List.generate(data.length, (index) {
      return Column(children: <Widget>[
        Indicator(
          color: colors[index],
          text: data.keys.elementAt(index),
          isSquare: true,
        ),
        SizedBox(
          height: 4,
        )
      ]);
    });
  }

  List<PieChartSectionData> showingSections() {
    Map<String, double> data = GetData();
    return List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      return PieChartSectionData(
          color: colors[i],
          value: data.values.elementAt(i),
          title: data.keys.elementAt(i),
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
          badgeWidget: isTouched
              ? Container(
                  padding: EdgeInsets.all(16),
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

  Map<String, double> GetData() {
    List<Expenditure> results = DatabaseHandler.expendituresList;
    List<Expenditure> dataToPlot = List.empty(growable: true);
    Set<String> categoriesToPlot = {};
    Map<String, double> dataToPlotGroupedBycategories = {};
    totalValueDisplayed = 0.0;
    //Filters by date
    for (var element in results) {
      DateTime date = element.date;
      switch (type) {
        case PieType.monthly:
          if (date.month == mmyy.month && date.year == mmyy.year) {
            categoriesToPlot.add(element.category);
            dataToPlot.add(element);
          }

          break;
        case PieType.yearly:
          if (date.year == mmyy.year) {
            categoriesToPlot.add(element.category);
            dataToPlot.add(element);
          }
          break;
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
}

class PieSectionData {
  double value;
  String title;
  PieSectionData({required this.value, required this.title});
}
