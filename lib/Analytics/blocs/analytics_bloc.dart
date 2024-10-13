import 'dart:ffi';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:ledgerstats/Categories/utils/category_utils.dart';
import 'package:ledgerstats/database_handler.dart';
import 'package:ledgerstats/Expenses/utils/expenditure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ledgerstats/Analytics/utils/charts.dart' as charts;
import 'package:ledgerstats/tuple.dart';
import 'package:sqflite/utils/utils.dart';

class MonthDisplay {
  static final Map<int, String> intToStrMonths = {
    //TODO localization
    1: 'jan',
    2: 'feb',
    3: 'mar',
    4: 'apr',
    5: 'may',
    6: 'jun',
    7: 'jul',
    8: 'aug',
    9: 'sep',
    10: 'oct',
    11: 'nov',
    12: 'dec'
  };
  final Map<String, String> strToIntMonths = {
    //TODO localization
    'jan': '1',
    'feb': '2',
    'mar': '3',
    'apr': '4',
    'may': '5',
    'jun': '6',
    'jul': '7',
    'aug': '8',
    'sep': '9',
    'oct': '10',
    'nov': '11',
    'dec': '12'
  };
  int m;
  int y;
  MonthDisplay({required this.m, required this.y});
  @override
  String toString() => '${intToStrMonths[m]} $y';
  @override
  bool operator ==(Object other) {
    return other is MonthDisplay && m == other.m && y == other.y;
  }

  @override
  int get hashCode => m ^ (y + 1) + y ^ (m + 2);
  bool operator >(Object other) {
    return other is MonthDisplay &&
        (y > other.y || (y == other.y && m > other.m));
  }
}

//events
abstract class PieChartEvent {
  final int tabIndex;
  PieChartEvent({this.tabIndex = -1});
}
class PieChartDataTuple {
  final Map<CategoryDescriptor, double> map;
  final double totalValue;

  // Constructor
  PieChartDataTuple({required this.map, required this.totalValue});
}
class ChangePieChartType extends PieChartEvent {
  final charts.ChartsType chartType;
  ChangePieChartType({required this.chartType, int tabIndex = -1})
      : super(tabIndex: tabIndex);
  @override
  String toString() => 'changeChartType { type: $chartType }';
}

class ChangePieChartCategoriesDisplayed extends PieChartEvent {
  final bool showAllCategories;
  ChangePieChartCategoriesDisplayed(
      {required this.showAllCategories, int tabIndex = -1})
      : super(tabIndex: tabIndex);
  @override
  String toString() =>
      'ChangePieChartCategoriesDisplayed { bool: $showAllCategories }';
}

class ChangePieChartDate extends PieChartEvent {
  final String month;
  final String year;
  ChangePieChartDate(
      {required this.month, required this.year, int tabIndex = -1})
      : super(tabIndex: tabIndex);
  @override
  String toString() => 'changeChartDate { date: $month/$year }';
}

//states
abstract class PieChartState {
  final charts.ChartsType chartType;
  final String month;
  final String year;
  final int tabIndex;
  final bool showAllCategories;
  final Data data;
  late final PieChartDataTuple groupedData;
  PieChartState(
      {required this.groupedData,
      required this.data,
      required this.chartType,
      required this.month,
      required this.year,
      required this.showAllCategories,
      this.tabIndex = -1});
  PieChartState.create(PieChartBloc bloc,
      {required this.data,
      required this.chartType,
      required this.month,
      required this.year,
      required this.showAllCategories,
      this.tabIndex = -1}) {
    groupedData = bloc.getCategorizedDataByMonth();
  }
}

class PieChartChanged extends PieChartState {
  PieChartChanged(
      {required PieChartDataTuple groupedData,
      required Data data,
      required charts.ChartsType chartType,
      required String month,
      required String year,
      required bool showAllCategories,
      int tabIndex = -1})
      : super(
            groupedData: groupedData,
            data: data,
            chartType: chartType,
            month: month,
            year: year,
            tabIndex: tabIndex,
            showAllCategories: showAllCategories);
  @override
  charts.ChartsType get type => chartType;
  @override
  String toString() =>
      'chartChanged { type: $chartType, date: $month/$year ,displayAll : $showAllCategories}';
}

//Bloc
class PieChartBloc extends Bloc<PieChartEvent, PieChartState> {
  charts.ChartsType chartType = charts.ChartsType.monthlyPie;
  String month;
  String year;
  Set<String> months = {};
  Set<String> years = {};
  PieChartState? previousState;
  bool showAllCategories;
  Data data;
  PieChartBloc(
      {required this.data,
      required this.month,
      required this.year,
      required this.showAllCategories})
      : super(
          PieChartChanged(
              groupedData: getCategorizedDataByMonth_static(
                  data.expenses, year, month, showAllCategories),
              tabIndex: 0,
              data: data,
              showAllCategories: false,
              chartType: charts.ChartsType.monthlyPie,
              month: month,
              year: year),
        ) {
    List<Expenditure> results = data.expenses;
    for (var element in results) {
      DateTime date = element.date;
      months.add(date.month.toString());
      years.add(date.year.toString());
    }
    previousState = state;
    on<ChangePieChartDate>(onDateChanged);
    on<ChangePieChartType>(onTypeChanged);
    on<ChangePieChartCategoriesDisplayed>(onChangePieChartCategoriesDisplayed);
  }

  PieChartBloc.unique(
      {required this.data,
      required this.chartType,
      required this.month,
      required this.year,
      required this.showAllCategories})
      : super(PieChartChanged(
            groupedData: getCategorizedDataByMonth_static(
                data.expenses, year, month, showAllCategories),
            data: data,
            showAllCategories: showAllCategories,
            chartType: chartType,
            month: month,
            year: year)) {}

  void onDateChanged(ChangePieChartDate event, Emitter<PieChartState> emit) {
    month = event.month;
    year = event.year;
    previousState = state;
    PieChartDataTuple groupedData;
    switch (chartType) {
      case charts.ChartsType.monthlyPie:
        groupedData = getCategorizedDataByMonth();
        break;
      case charts.ChartsType.yearlyPie:
        groupedData = getCategorizedDataByYear();
        break;
      default:
        groupedData = getCategorizedDataByMonth();
    }
    emit(PieChartChanged(
        groupedData: groupedData,
        data: data,
        showAllCategories: showAllCategories,
        chartType: chartType,
        month: event.month,
        year: event.year,
        tabIndex: event.tabIndex));
  }

  void onTypeChanged(ChangePieChartType event, Emitter<PieChartState> emit) {
    chartType = event.chartType;
    previousState = state;
    PieChartDataTuple groupedData;
    switch (chartType) {
      case charts.ChartsType.monthlyPie:
        groupedData = getCategorizedDataByMonth();
        break;
      case charts.ChartsType.yearlyPie:
        groupedData = getCategorizedDataByYear();
        break;
      default:
        groupedData = getCategorizedDataByMonth();
    }
    emit(PieChartChanged(
        groupedData: groupedData,
        data: data,
        showAllCategories: showAllCategories,
        chartType: event.chartType,
        month: month,
        year: year,
        tabIndex: event.tabIndex));
  }

  void onChangePieChartCategoriesDisplayed(
      ChangePieChartCategoriesDisplayed event, Emitter<PieChartState> emit) {
    showAllCategories = event.showAllCategories;
    previousState = state;
    PieChartDataTuple groupedData;
    switch (chartType) {
      case charts.ChartsType.monthlyPie:
        groupedData = getCategorizedDataByMonth();
        break;
      case charts.ChartsType.yearlyPie:
        groupedData = getCategorizedDataByYear();
        break;
      default:
        groupedData = getCategorizedDataByMonth();
    }
    emit(PieChartChanged(
        groupedData: groupedData,
        data: data,
        showAllCategories: event.showAllCategories,
        chartType: chartType,
        month: month,
        year: year,
        tabIndex: event.tabIndex));
  }

  PieChartDataTuple getCategorizedDataByYear() {
    List<Expenditure> results = data.expenses;

    List<Expenditure> dataToPlot = List.empty(growable: true);
    Set<CategoryDescriptor> categoriesToPlot = {};
    Map<CategoryDescriptor, double> dataToPlotGroupedBycategories = {};
    double totalValueDisplayed = 0.0;
    //Filters by date
    DateTime yy = DateTime(int.parse(year));
    for (Expenditure exp in results) {
      DateTime date = exp.date;
      bool categoryIsARoot = exp.category.parent == null;
      if (date.year == yy.year && (showAllCategories || categoryIsARoot)) {
        categoriesToPlot.add(exp.category);
        dataToPlot.add(exp);
      } else if (date.year == yy.year &&
          !(showAllCategories || categoryIsARoot)) {
        dataToPlot.add(Expenditure(
            title: exp.title,
            category: exp.category.parent!,
            value: exp.value,
            date: date,
            dataBaseId: exp.dataBaseId));
      }}
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

    return PieChartDataTuple(map:dataToPlotGroupedBycategories,totalValue:totalValueDisplayed);
  }

  PieChartDataTuple getCategorizedDataByMonth() {
    List<Expenditure> results = data.expenses;
    String year = this.year;
    String month = this.month;
    return getCategorizedDataByMonth_static(
        results, year, month, showAllCategories);
  }

  static PieChartDataTuple getCategorizedDataByMonth_static(
      List<Expenditure> results,
      String year,
      String month,
      bool showAllCategories) {
    List<Expenditure> dataToPlot = List.empty(growable: true);
    Set<CategoryDescriptor> categoriesToPlot = {};
    Map<CategoryDescriptor, double> dataToPlotGroupedBycategories = {};
    double totalValueDisplayed = 0.0;
    //Filters by date
    DateTime mmyy = DateTime(int.parse(year), int.parse(month));
    for (Expenditure exp in results) {
      DateTime date = exp.date;
      bool categoryIsARoot = exp.category.parent == null;
      //Test if category date is in time range
      if( date.month == mmyy.month && date.year == mmyy.year){
        //If showAllCategories then adds all categories to display
        if(showAllCategories){
          categoriesToPlot.add(exp.category);
          dataToPlot.add(exp);
        }
        else {
          //showAllCategories is False so we discriminate expenses based on whether the category is a root or not
          if(categoryIsARoot){
            //Else, if the category is a root, then adds it to display
            categoriesToPlot.add(exp.category);
            dataToPlot.add(exp);
          }else{
            //Category has a parent, we shall add the expense to the parent category
            //And add the parent category to the plot set if not already present
            categoriesToPlot.add(exp.category.parent!);
            dataToPlot.add(Expenditure(
                title: exp.title,
                category: exp.category.parent!,
                value: exp.value,
                date: date,
                dataBaseId: exp.dataBaseId));
          }
        }
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
        ifAbsent: () {return element.value;},
      );
    }

    //WIP to sort categories
    CategoryDescriptor other = CategoryDescriptor(name: "Other", emoji: "\u2754", descriptors: [], id: 0);
    bool concatenateToOther = false;
    if(categoriesToPlot.length > 9){
      concatenateToOther = true;

    }
    List<CategoryDescriptor> sortedCategories = List.empty(growable: true);
    //Sort and aggregate to other if necessary
    List<MapEntry<CategoryDescriptor,double>> sortedData = List.from(dataToPlotGroupedBycategories.entries);
    //Sort in reverse order
    mergeSort(sortedData,compare: (MapEntry<CategoryDescriptor,double> a ,MapEntry<CategoryDescriptor,double>b){return a.value > b.value ? -1 : (a.value < b.value ? 1 : 0);});
    Map<CategoryDescriptor, double> finalData = {};
    if(concatenateToOther){
      finalData[other] = 0;
      for(MapEntry<CategoryDescriptor,double> entry in sortedData){
        if(finalData.length <= 9){
          finalData[entry.key] = entry.value;
        }
        else{
          finalData[other] = finalData[other]!+entry.value;
        }

      }
    }
    else{
    finalData = dataToPlotGroupedBycategories;
    }
    //Normalize and converts to % for display on a pie chart
    for (var element in finalData.keys) {
      double tmpValue = finalData[element]!;
      tmpValue /= totalValueDisplayed;
      tmpValue *= 100;
      finalData[element] = tmpValue;
    }
    return PieChartDataTuple(map:finalData,totalValue: totalValueDisplayed);
  }

}

//BarCharts
//events
class BarChartEvent {
  const BarChartEvent();
}

class DatesAddedEvent extends BarChartEvent {
  List<MonthDisplay> dates;
  DatesAddedEvent({required this.dates});
}

class DatesRemovedEvent extends BarChartEvent {
  List<MonthDisplay> dates;
  DatesRemovedEvent({required this.dates});
}

//states
class BarChartState {
  List<MonthDisplay> dates;
  Tuple<Map<String, Map<CategoryDescriptor, double>>, Set<CategoryDescriptor>>
      groupedData;
  BarChartState({required this.groupedData, required this.dates});
  @override
  String toString() => ('BarChartState : $dates');
}

//BLoC
class BarChartBloc extends Bloc<BarChartEvent, BarChartState> {
  Data data;
  List<MonthDisplay> dates = List.empty(growable: true);
  BarChartBloc({required this.data})
      : super(BarChartState(
            groupedData: getDataByMonths_static([], data.expenses),
            dates: [])) {
    on<DatesAddedEvent>(onDatesAddedEvent);
    on<DatesRemovedEvent>(onDatesRemovedEvent);
  }

  void onDatesAddedEvent(DatesAddedEvent event, Emitter<BarChartState> emit) {
    dates.addAll(event.dates);
    Tuple<Map<String, Map<CategoryDescriptor, double>>, Set<CategoryDescriptor>>
        groupedData = getDataByMonths_static(dates, data.expenses);
    emit(BarChartState(groupedData: groupedData, dates: dates));
  }

  void onDatesRemovedEvent(
      DatesRemovedEvent event, Emitter<BarChartState> emit) {
    for (MonthDisplay date in event.dates) {
      if (dates.contains(date)) {
        dates.remove(date);
      }
    }

    Tuple<Map<String, Map<CategoryDescriptor, double>>, Set<CategoryDescriptor>>
        groupedData = getDataByMonths_static(dates, data.expenses);
    emit(BarChartState(groupedData: groupedData, dates: dates));
  }

  static List<MonthDisplay> bubbleSort(List<MonthDisplay> list) {
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

  static Tuple<Map<String, Map<CategoryDescriptor, double>>,
          Set<CategoryDescriptor>>
      getDataByMonths_static(
          List<MonthDisplay> dates, List<Expenditure> results) {
    dates = bubbleSort(dates);
    Map<String, Map<CategoryDescriptor, double>> data = {};
    Set<CategoryDescriptor> categories = {};
    for (MonthDisplay monthYear in dates) {
      Map<CategoryDescriptor, double> dataAggregate =
          getDataByMonth_static(monthYear, results);
      categories.addAll(dataAggregate.keys);
      data[monthYear.toString()] = dataAggregate;
    }
    return Tuple(data, categories);
  }

  static Map<CategoryDescriptor, double> getDataByMonth_static(
      MonthDisplay monthYear, List<Expenditure> results) {
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
      } else if (date.month == mmyy.month &&
          date.year == mmyy.year &&
          !categoryIsARoot) {
        //Category is not a root, we will recreate a false expense for this one but under the parent category
        categoriesToPlot.add(element.category.parent!);
        dataToPlot.add(Expenditure(
            title: element.title,
            category: element.category.parent!,
            value: element.value,
            date: date,
            dataBaseId: element.dataBaseId));
      }
    }
    //WIP to sort categories
    CategoryDescriptor other = CategoryDescriptor(name: "Other", emoji: "\u2754", descriptors: [], id: 0);
    bool concatenateToOther = false;
    if(categoriesToPlot.length > 10){
      concatenateToOther = true;    

      }
  List<CategoryDescriptor> sortedCategories = List.empty(growable: true);
    //WIP
    for (Expenditure element in dataToPlot) {
        mergeSort(dataToPlot,compare: (Expenditure a ,Expenditure b ) {return a > b ? 1 : (a < b ? -1 : 0);});
      }

    //Aggregate by categories
    for (CategoryDescriptor element in categoriesToPlot) {
      dataToPlotGroupedBycategories[element] = 0;
    }
    for (int i = 0; i < min(dataToPlot.length,10); i++) {
      Expenditure element = dataToPlot[i];
      dataToPlotGroupedBycategories.update(
        element.category,
        (value) => element.value + value,
        ifAbsent: () => element.value,
      );
      //Sort and aggregate to other if necessary
      List<MapEntry<CategoryDescriptor,double>> sortedData = List.from(dataToPlotGroupedBycategories.entries);
      mergeSort(sortedData,compare: (MapEntry<CategoryDescriptor,double> a ,MapEntry<CategoryDescriptor,double>b){return a.value > b.value ? 1 : (a.value < b.value ? -1 : 0);});
      Map<CategoryDescriptor, double> finalData = {};
      if(concatenateToOther){
        finalData[other] = 0;
        for(MapEntry<CategoryDescriptor,double> entry in sortedData){
          if(finalData.length < 9){
            finalData[entry.key] = entry.value;
          }
          else{
            finalData[other] = finalData[other]!+entry.value;
          }

        }
      }

    }
    return dataToPlotGroupedBycategories;
  }
}
