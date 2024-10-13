import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ledgerstats/Expenses/utils/expenditure.dart';
import 'package:ledgerstats/database_handler.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(ExpensesLoading()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  void _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit){
    emit(
      ExpensesLoaded(expenses:event.expenses),
    );
  }
  void _onAddExpense(AddExpense event, Emitter<ExpenseState> emit){
    final state = this.state;
    DatabaseHandler().updateData(event.expense);
    if (state is ExpensesLoaded){
      emit(ExpensesLoaded(expenses: List.from(state.expenses)..add(event.expense)),);
    }
  }
  void _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit){}
  void _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit){
    final state = this.state;
    if (state is ExpensesLoaded){
      List<Expenditure> expenses =  state.expenses.where((expense) {
        return expense.dataBaseId != event.expense.dataBaseId;
      }).toList();
      emit(ExpensesLoaded(expenses: expenses));
    }
  }
}
