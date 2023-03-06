import 'package:budgetizer/Icons_Selector/category_utils.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:budgetizer/expenditure.dart';
import 'package:budgetizer/indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryPie extends StatefulWidget {
  late PieType pieType;
  CategoryPie({super.key, required this.pieType});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

enum PieType { monthly, yearly }

Map<String, String> int2TextMonths = {
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
  Set<String> months = {};
  Set<String> years = {};
  String month = DatabaseHandler.expendituresList.first.date.month.toString();
  String year = DatabaseHandler.expendituresList.first.date.year.toString();

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
              Row(children: <Widget>[
                const SizedBox(
                  width: 28,
                ),
                Row(children: showingDropDownButtons())
              ]),
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
                          centerSpaceRadius: 80,
                          sections: showingSections(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: showingIndicators(),
              ),
            ],
          )),
      /*Flexible(child: ListView(children: showingListTiles()))*/
    ]));
  }

  List<Widget> showingIndicators() {
    Map<CategoryDescriptor, double> data = getData();
    return List.generate(data.length, (index) {
      return Column(children: <Widget>[
        Row(
          children: [
            Indicator(
              color: colors[index],
              text: data.keys.elementAt(index).name,
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
          color: colors[i],
          value: data.values.elementAt(i),
          title: data.keys.elementAt(i).name,
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
    for (var element in results) {
      DateTime date = element.date;
      months.add(date.month.toString());
    }
    return List.generate(months.length, (index) {
      return DropdownMenuItem<String>(
          value: months.elementAt(index),
          child: Text(
            int2TextMonths[months.elementAt(index)]!,
          ));
    });
  }

  List<DropdownMenuItem<String>> getYears() {
    List<Expenditure> results = DatabaseHandler.expendituresList;
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
          value: years.first,
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
    Map<CategoryDescriptor, double> data = getData();
    return List.generate(data.length, (index) {
      return ListTile(
          leading: Text(data.keys.elementAt(index).emoji),
          title: Text(data.keys.elementAt(index).name == "error"
              ? AppLocalizations.of(context)!.noCategoryName
              : data.keys.elementAt(index).name),
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
