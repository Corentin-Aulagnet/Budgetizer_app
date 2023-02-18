import 'package:budgetizer/Icons%20Selector/IconListTile.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:budgetizer/expenditure.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:budgetizer/create_category_view.dart';
import 'package:searchable_listview/searchable_listview.dart';

class AddExpenditureView extends StatefulWidget {
  const AddExpenditureView({super.key});
  @override
  State<AddExpenditureView> createState() => _AddExpenditureViewState();
}

class _AddExpenditureViewState extends State<AddExpenditureView> {
  List<String> availableCurrencies = ["€Eur", "\$US"];
  double value = 0.0;
  String currencySelected = '';

  FocusNode title_FocusNode = new FocusNode();
  bool title_hasInputError = false;
  String title_text = '';
  CategoryDescriptor category = DatabaseHandler.categoriesList.length > 0
      ? DatabaseHandler.categoriesList[0]
      : CategoryDescriptor.Error();
  DateTime date = DateTime.now();
  @override
  void initState() {
    super.initState();
    currencySelected = availableCurrencies[0];

    title_FocusNode.addListener(() {
      if (!title_FocusNode.hasFocus) {
        setState(() {
          //title_hasInputError = //Check your conditions on text variable
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHandler().LoadCategories();
    return GestureDetector(
        onTap: () {
          //called when the body of the screen is touched
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add a new Expenditure'),
            leading: const BackButton(),
          ),
          body: Column(children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'title',
                labelText: 'Title',
              ),
              onChanged: (String? value) {
                // This optional block of code can be used to run
                // code when the user saves the form.
                if (value != null) title_text = value;
              },
              validator: (String? value) {
                return (value != null) ? 'Do not use the @ char.' : null;
              },
            ),
            Row(children: [
              Text("Category Selected"),
              Expanded(
                  child: CategoryItem(
                category: category,
                color: category.color,
                notifyParent: () {},
                displayBin: false,
              ))
            ]),
            Row(
              children: <Widget>[
                Expanded(
                    child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'amount',
                    labelText: 'Amount',
                  ),
                  onChanged: (String? value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                    if (value != null) this.value = double.parse(value);
                  },
                  validator: (String? value) {
                    return (value != null &&
                            value.contains(RegExp(
                                '[a-zA-Z&é\"\'()-è`_\\ç^à@\[\]=+\{\}]+')))
                        ? 'Use only numbers'
                        : null;
                  },
                )),
                Expanded(
                  child: DropdownButton<String>(
                    value: currencySelected,
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        currencySelected = value!; //Code to run
                      });
                    },
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                          value: availableCurrencies[0],
                          child: Text(availableCurrencies[0])),
                      DropdownMenuItem(
                          value: availableCurrencies[1],
                          child: Text(availableCurrencies[1]))
                    ],
                  ),
                ),
              ],
            ),
            Row(children: <Widget>[
              Expanded(
                child: DateTimeField(
                  initialValue: DateTime.now(),
                  format: DateFormat.yMd('fr_Fr'),
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                  onChanged: (DateTime? currentValue) =>
                      {if (currentValue != null) date = currentValue},
                ),
              )
            ]),
            Expanded(
                flex: 10,
                child: SearchableList<CategoryDescriptor>(
                    key: UniqueKey(),
                    initialList: DatabaseHandler.categoriesList +
                        [
                          CategoryDescriptor(
                              id: 0,
                              icon: Icons.add,
                              name: "Create a category",
                              descriptors: [""],
                              color: Color(0xff000000))
                        ],
                    filter: (value) => DatabaseHandler.categoriesList
                        .where(
                          (element) =>
                              element.name.toLowerCase().contains(value),
                        )
                        .toList(),
                    builder: (CategoryDescriptor category) {
                      if (category.name == "Create a category") {
                        return CategoryItem(
                          category: category,
                          color: category.color,
                          notifyParent: () {},
                          displayBin: false,
                        );
                      } else {
                        return CategoryItem(
                          category: category,
                          color: category.color,
                          notifyParent: refresh,
                        );
                      }
                    },
                    inputDecoration: InputDecoration(
                      labelText: "Search Category",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onItemSelected: (CategoryDescriptor category) {
                      if (category.name == "Create a category") {
                        //Push the view to create a category
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateCategoryView()),
                        ).then((_) => setState(() {}));
                      } else {
                        //Select the category
                        setState(() {
                          this.category = category;
                        });
                      }
                    }))
          ]),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                bool added = await AddExpenditureToDatabase();
                if (added) {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                }
              },
              child: const Icon(Icons.save)),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ));
  }

  refresh() async {
    print('refresh');
    await DatabaseHandler().LoadCategories();
    setState(() {});
  }

  Future<bool> AddExpenditureToDatabase() async {
    //Validates that all mandatory fields are filled
    if (title_text == '' || value == 0.0 || date == DateTime(1800, 1, 1)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'All fields must be filled ${title_text == '' ? 'Title' : ''} ${category == '' ? 'Category' : ''}${value == 0.0 ? 'Amount' : ''}')));
      return false;
    } else {
      Expenditure exp = Expenditure(
          title: title_text, category: category, value: value, date: date);
      await DatabaseHandler().InsertData(exp);
    }
    return true;
  }
}
