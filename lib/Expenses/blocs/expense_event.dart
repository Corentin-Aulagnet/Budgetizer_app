part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final List<Expenditure> expenses;
  const LoadExpenses({this.expenses = const <Expenditure>[]});

  @override
  List<Object> get props => [expenses];
}

class AddExpense extends ExpenseEvent {
  final Expenditure expense;
  const AddExpense({required this.expense});
  @override
  List<Object> get props => [expense];
}
class UpdateExpense extends ExpenseEvent {
  final Expenditure expense;
  const UpdateExpense({required this.expense});
  @override
  List<Object> get props => [expense];
}
class DeleteExpense extends ExpenseEvent {
  final Expenditure expense;
  const DeleteExpense({required this.expense});
  @override
  List<Object> get props => [expense];
}

