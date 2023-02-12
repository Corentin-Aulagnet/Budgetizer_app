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
  String month = '12';
  String year = '2021';

  double totalValueDisplayed = 0.0;

  @override
  Widget build(BuildContext context) {
    type = widget.pieType;
    return Expanded(
        child: Column(children: [
      Card(
          color: Colors.white,
          child: Column(
            children: [
              Row(
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
              Center(child: Row(children: showingDropDownButtons())),
            ],
          )),
      Flexible(child: ListView(children: showingListTiles()))
    ]));
  }

  List<Widget> showingIndicators() {
    Map<String, double> data = getData();
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
    Map<String, double> data = getData();
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

  Map<String, double> getData() {
    List<Expenditure> results = DatabaseHandler.expendituresList;
    List<Expenditure> dataToPlot = List.empty(growable: true);
    Set<String> categoriesToPlot = {};
    Map<String, double> dataToPlotGroupedBycategories = {};
    totalValueDisplayed = 0.0;
    //Filters by date
    mmyy = DateTime(int.parse(year), int.parse(month));
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

  List<DropdownMenuItem<String>> getMonths() {
    List<Expenditure> results = DatabaseHandler.expendituresList;
    Set<String> months = {};
    for (var element in results) {
      DateTime date = element.date;
      months.add(date.month.toString());
    }
    return List.generate(months.length, (index) {
      return DropdownMenuItem<String>(
          value: months.elementAt(index),
          child: Text(
            months.elementAt(index),
          ));
    });
  }

  List<DropdownMenuItem<String>> getYears() {
    List<Expenditure> results = DatabaseHandler.expendituresList;
    Set<String> years = {};
    for (var element in results) {
      DateTime date = element.date;
      years.add(date.year.toString());
    }
    return List.generate(years.length, (index) {
      return DropdownMenuItem<String>(
          value: years.elementAt(index),
          child: Text(
            years.elementAt(index),
          ));
    });
  }

  List<Widget> showingDropDownButtons() {
    if (type == PieType.monthly) {
      return <Widget>[
        DropdownButton<String>(
          value: month,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              Scaffold.of(context).setState(() {});
              month = value!; //Code to run
            });
          },
          items: getMonths(),
        ),
        DropdownButton<String>(
          value: year,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              Scaffold.of(context).setState(() {});
              year = value!; //Code to run
            });
          },
          items: getYears(),
        ),
      ];
    } else {
      return <Widget>[
        DropdownButton<String>(
          value: year,
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              Scaffold.of(context).setState(() {});
              year = value!; //Code to run
            });
          },
          items: getYears(),
        ),
      ];
    }
  }

  List<Widget> showingListTiles() {
    Map<String, double> data = getData();
    return List.generate(data.length, (index) {
      return ListTile(
          leading: Text(data.keys.elementAt(index)),
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
