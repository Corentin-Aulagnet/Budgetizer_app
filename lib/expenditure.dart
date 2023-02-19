import 'package:budgetizer/Icons%20Selector/IconListTile.dart';
import 'package:budgetizer/database_handler.dart';

class Expenditure {
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
  Expenditure.Copy(Expenditure exp) {
    this.category = exp.category;
    this.value = exp.value;
    this.date = exp.date;
    this.title = exp.title;
    this.dataBaseId = exp.dataBaseId;
  }
  Expenditure.Error() {
    title = '';
    category = CategoryDescriptor.Error();
    value = double.nan;
    date = DatabaseHandler.defaultDate;
    dataBaseId = -1;
  }
  @override
  String toString() {
    return '$title, ${category.toString()}, ${value.toString()}, ${date.toString()}';
  }
}
