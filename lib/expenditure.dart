import 'package:budgetizer/Icons_Selector/category_utils.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:flutter/material.dart';

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
  @override
  String toString() {
    return '$title, ${category.toString()}, ${value.toString()}, ${date.toString()}';
  }
}
