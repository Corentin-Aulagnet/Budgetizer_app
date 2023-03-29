import 'package:budgetizer/database_handler.dart';
import 'package:budgetizer/Expenses/expenditure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetizer/charts.dart' as charts;

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
  final List<String> month;
  final List<String> year;
  ChangePieChartDate(
      {required this.month, required this.year, int tabIndex = -1})
      : super(tabIndex: tabIndex);
  @override
  String toString() => 'changeChartDate { date: $month/$year }';
}

//states
abstract class PieChartState {
  final charts.ChartsType chartType;
  final List<String> month;
  final List<String> year;
  final int tabIndex;
  final bool showAllCategories;
  const PieChartState(
      {required this.chartType,
      required this.month,
      required this.year,
      required this.showAllCategories,
      this.tabIndex = -1});
}

class PieChartChanged extends PieChartState {
  const PieChartChanged(
      {required charts.ChartsType chartType,
      required List<String> month,
      required List<String> year,
      required bool showAllCategories,
      int tabIndex = -1})
      : super(
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
  late List<String> month;
  late List<String> year;
  Set<String> months = {};
  Set<String> years = {};
  PieChartState? previousState;
  bool showAllCategories = false;
  PieChartBloc()
      : super(
          PieChartChanged(
              tabIndex: 0,
              showAllCategories: false,
              chartType: charts.ChartsType.monthlyPie,
              month: [
                DatabaseHandler.expendituresList.first.date.month.toString()
              ],
              year: [
                DatabaseHandler.expendituresList.first.date.year.toString()
              ]),
        ) {
    List<Expenditure> results = DatabaseHandler.expendituresList;
    for (var element in results) {
      DateTime date = element.date;
      months.add(date.month.toString());
      years.add(date.year.toString());
    }
    previousState = state;
    month = [months.first];
    year = [years.first];
    on<ChangePieChartDate>(onDateChanged);
    on<ChangePieChartType>(onTypeChanged);
    on<ChangePieChartCategoriesDisplayed>(onChangePieChartCategoriesDisplayed);
  }
  PieChartBloc.unique(
      {required this.chartType,
      required this.month,
      required this.year,
      required this.showAllCategories})
      : super(PieChartChanged(
            showAllCategories: showAllCategories,
            chartType: chartType,
            month: month,
            year: year)) {
    List<Expenditure> results = DatabaseHandler.expendituresList;
    for (var element in results) {
      DateTime date = element.date;
      months.add(date.month.toString());
      years.add(date.year.toString());
    }
    on<ChangePieChartDate>(onDateChanged);
    on<ChangePieChartType>(onTypeChanged);
  }

  void onDateChanged(ChangePieChartDate event, Emitter<PieChartState> emit) {
    month = event.month;
    year = event.year;
    previousState = state;
    emit(PieChartChanged(
        showAllCategories: showAllCategories,
        chartType: chartType,
        month: event.month,
        year: event.year,
        tabIndex: event.tabIndex));
  }

  void onTypeChanged(ChangePieChartType event, Emitter<PieChartState> emit) {
    chartType = event.chartType;
    previousState = state;
    emit(PieChartChanged(
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
    emit(PieChartChanged(
        showAllCategories: event.showAllCategories,
        chartType: chartType,
        month: month,
        year: year,
        tabIndex: event.tabIndex));
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
  BarChartState({required this.dates});
  @override
  String toString() => ('BarChartState : $dates');
}

//BLoC
class BarChartBloc extends Bloc<BarChartEvent, BarChartState> {
  static List<MonthDisplay> dates = List.empty(growable: true);
  BarChartBloc() : super(BarChartState(dates: dates)) {
    on<DatesAddedEvent>(onDatesAddedEvent);
    on<DatesRemovedEvent>(onDatesRemovedEvent);
  }

  void onDatesAddedEvent(DatesAddedEvent event, Emitter<BarChartState> emit) {
    dates.addAll(event.dates);
    //dates.add(event.date);
    emit(BarChartState(dates: dates));
  }

  void onDatesRemovedEvent(
      DatesRemovedEvent event, Emitter<BarChartState> emit) {
    for (MonthDisplay date in event.dates) {
      if (dates.contains(date)) {
        dates.remove(date);
        emit(BarChartState(dates: dates));
      }
    }
  }
}
