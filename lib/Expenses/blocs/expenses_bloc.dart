import 'package:budgetizer/Categories/utils/category_utils.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

//Events
abstract class ExpenseFilterEvent {}

class AddToFilter extends ExpenseFilterEvent {
  CategoryDescriptor category;
  AddToFilter({required this.category});
}

class AddAllToFilter extends ExpenseFilterEvent {
  List<CategoryDescriptor> categories;
  AddAllToFilter({required this.categories});
}

class RemoveFromFilter extends ExpenseFilterEvent {
  CategoryDescriptor category;
  RemoveFromFilter({required this.category});
}

class RemoveAllFromFilter extends ExpenseFilterEvent {
  RemoveAllFromFilter();
}

class ChangeFromDate extends ExpenseFilterEvent {
  DateTime? date;
  ChangeFromDate({required this.date});
}

class ChangeToDate extends ExpenseFilterEvent {
  DateTime? date;
  ChangeToDate({required this.date});
}

//State
class ExpenseFilterState {
  List<CategoryDescriptor> categoriesInFilter;
  DateTime? fromDate;
  DateTime? toDate;
  ExpenseFilterState(
      {this.categoriesInFilter = const [], this.fromDate, this.toDate});
}

//Bloc
class ExpenseFilterBloc extends Bloc<ExpenseFilterEvent, ExpenseFilterState> {
  List<CategoryDescriptor> categoriesInFilter;
  DateTime? fromDate;
  DateTime? toDate;
  ExpenseFilterBloc({required this.categoriesInFilter})
      : super(ExpenseFilterState(categoriesInFilter: categoriesInFilter)) {
    on<AddToFilter>(onAddToFilter);
    on<RemoveFromFilter>(onRemoveFromFilter);
    on<AddAllToFilter>(onAddAllToFilter);
    on<RemoveAllFromFilter>(onRemoveAllFromFilter);
    on<ChangeFromDate>(onChangeFromDate);
    on<ChangeToDate>(onChangeToDate);
  }

  void onAddToFilter(AddToFilter event, Emitter<ExpenseFilterState> emit) {
    categoriesInFilter.add(event.category);
    emit(ExpenseFilterState(categoriesInFilter: categoriesInFilter));
  }

  void onRemoveFromFilter(
      RemoveFromFilter event, Emitter<ExpenseFilterState> emit) {
    categoriesInFilter.remove(event.category);
    emit(ExpenseFilterState(categoriesInFilter: categoriesInFilter));
  }

  void onAddAllToFilter(
      AddAllToFilter event, Emitter<ExpenseFilterState> emit) {
    categoriesInFilter = event.categories;
    emit(ExpenseFilterState(categoriesInFilter: categoriesInFilter));
  }

  void onRemoveAllFromFilter(
      RemoveAllFromFilter event, Emitter<ExpenseFilterState> emit) {
    categoriesInFilter.clear();
    emit(ExpenseFilterState(categoriesInFilter: categoriesInFilter));
  }

  void onChangeFromDate(
      ChangeFromDate event, Emitter<ExpenseFilterState> emit) {
    fromDate = event.date;
    emit(ExpenseFilterState(
        categoriesInFilter: categoriesInFilter,
        fromDate: event.date,
        toDate: toDate));
  }

  void onChangeToDate(ChangeToDate event, Emitter<ExpenseFilterState> emit) {
    toDate = event.date;
    emit(ExpenseFilterState(
        categoriesInFilter: categoriesInFilter,
        fromDate: fromDate,
        toDate: event.date));
  }
}
