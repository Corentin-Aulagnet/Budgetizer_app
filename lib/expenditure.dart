class Expenditure {
  String title;
  String category;
  double value;
  DateTime date;
  Expenditure(
      {required this.title,
      required this.category,
      required this.value,
      required this.date});

  @override
  String toString() {
    return '$title, $category, ${value.toString()}, ${date.toString()}';
  }
}
