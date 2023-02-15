import 'package:budgetizer/Icons%20Selector/IconListTile.dart';

class Expenditure {
  late String title;
  late CategoryDescriptor category;
  late double value;
  late DateTime date;
  Expenditure(
      {required this.title,
      required this.category,
      required this.value,
      required this.date});
  Expenditure.Error() {
    title = '';
    category = CategoryDescriptor.createPlaceholder();
    value = double.nan;
    date = DateTime.now();
  }
  @override
  String toString() {
    return '$title, ${category.toString()}, ${value.toString()}, ${date.toString()}';
  }
}
