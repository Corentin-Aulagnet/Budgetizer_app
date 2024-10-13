part of 'expense_bloc.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();
  @override
  List<Object> get props => [];
}

class ExpensesLoading extends ExpenseState {}

class ExpensesLoaded extends ExpenseState {
  final List<Expenditure> expenses;

  const ExpensesLoaded({this.expenses = const <Expenditure>[]});


  @override
  List<Object> get props => [expenses];
}

