import 'package:ledgerstats/Categories/utils/category_utils.dart';
import 'package:ledgerstats/database_handler.dart';
import 'package:equatable/equatable.dart';
class Expenditure extends Equatable{
  late String title;
  late CategoryDescriptor category;
  late double value;
  late DateTime date;
  late int dataBaseId;
  Expenditure(
      {required this.title,
      required this.category,
      required this.value,
      required this.date,
      required this.dataBaseId});
  Expenditure.copy(Expenditure exp) {
    category = exp.category;
    value = exp.value;
    date = exp.date;
    title = exp.title;
    dataBaseId = exp.dataBaseId;
  }
  Expenditure.error() {
    title = '';
    category = CategoryDescriptor.error();
    value = double.nan;
    date = DatabaseHandler.defaultDate;
    dataBaseId = -1;
  }
  Expenditure.dummy() {
    title = '';
    category = CategoryDescriptor.error();
    value = double.nan;
    date = DateTime.now();
    dataBaseId = -1;
  }
  @override
  String toString() {
    return '$title, ${category.toString()}, ${value.toString()}, ${date.toString()}';
  }
  @override
  List<Object?> get props =>[
    title,
    category,
    dataBaseId,
  ];
  @override
  bool operator >(Expenditure other){
    return value > other.value;
  }
  @override
  bool operator <(Expenditure other){
    return value < other.value;
  }
}
