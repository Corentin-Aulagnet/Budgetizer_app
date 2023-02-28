import 'package:budgetizer/Icons%20Selector/IconListTile.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:budgetizer/expenditure.dart';
import 'package:budgetizer/home.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:budgetizer/create_category_view.dart';
import 'package:searchable_listview/searchable_listview.dart';

class AddExpenditureView extends StatefulWidget {
  AddExpenditureView({super.key, Expenditure? expenditure}) {
    if (expenditure == null) {
      this.expenditure = Expenditure.Error();
      isModifying = false;
    } else {
      this.expenditure = Expenditure.Copy(expenditure);
      isModifying = true;
    }
  }
  late Expenditure expenditure;
  late bool isModifying;
  @override
  State<AddExpenditureView> createState() => _AddExpenditureViewState();
}

class _AddExpenditureViewState extends State<AddExpenditureView> {
  List<String> availableCurrencies = ["€Eur", "\$US"];
  String currencySelected = '';

  bool titleHasInputError = false;

  @override
  void initState() {
    super.initState();
    currencySelected = availableCurrencies[0];
  }

  Widget titleFieldForm() {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'title',
        labelText: 'Title',
      ),
      initialValue: widget.expenditure.title,
      onChanged: (String? value) {
        // This optional block of code can be used to run
        // code when the user saves the form.
        if (value != null) widget.expenditure.title = value;
      },
      validator: (String? value) {
        return (value != null) ? 'Do not use the @ char.' : null;
      },
    );
  }

  Widget amountFieldForm() {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'amount',
        labelText: 'Amount',
      ),
      initialValue: widget.expenditure.value.toString(),
      onChanged: (String? value) {
        // This optional block of code can be used to run
        // code when the user saves the form.
        if (value != null) widget.expenditure.value = double.parse(value);
      },
      validator: (String? value) {
        return (value != null &&
                value.contains(RegExp('[a-zA-Z&é\"\'()-è`_\\ç^à@\[\]=+\{\}]+')))
            ? 'Use only numbers'
            : null;
      },
    );
  }

  Widget categoriesSearchableList() {
    return SearchableList<CategoryDescriptor>(
        key: UniqueKey(),
        initialList: DatabaseHandler.categoriesList +
            [
              CategoryDescriptor(
                id: 0,
                emoji: '\u2795',
                name: "Create a category",
                descriptors: [""],
              )
            ],
        filter: (value) => DatabaseHandler.categoriesList
            .where(
              (element) => element.name.toLowerCase().contains(value),
            )
            .toList(),
        builder: (CategoryDescriptor category) {
          if (category.name == "Create a category") {
            return CategoryItem(
              category: category,
              notifyParent: () {},
              displayBin: false,
            );
          } else {
            return CategoryItem(
              category: category,
              notifyParent: refresh,
            );
          }
        },
        inputDecoration: InputDecoration(
          labelText: "Search Category",
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(primaryColor),
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
              MaterialPageRoute(builder: (context) => CreateCategoryView()),
            ).then((_) => setState(() {}));
          } else {
            //Select the category
            setState(() {
              widget.expenditure.category = category;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHandler().LoadCategories();
    FocusManager.instance.primaryFocus?.unfocus();
    return GestureDetector(
        onTap: () {
          //called when the body of the screen is touched
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title:
                Text(widget.isModifying ? 'Modify' : 'Add a new Expenditure'),
            leading: const BackButton(),
          ),
          body: Column(children: <Widget>[
            titleFieldForm(),
            Row(children: [
              const Text("Category Selected"),
              Expanded(
                  child: CategoryItem(
                category: widget.expenditure.category,
                notifyParent: () {},
                displayBin: false,
              ))
            ]),
            Row(
              children: <Widget>[
                Expanded(child: amountFieldForm()),
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
                  initialValue: widget.expenditure.date,
                  format: DateFormat.yMd('fr_Fr'),
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue == DatabaseHandler.defaultDate
                            ? DateTime.now()
                            : currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                  onChanged: (DateTime? currentValue) => {
                    if (currentValue != null)
                      widget.expenditure.date = currentValue
                  },
                ),
              )
            ]),
            Expanded(flex: 10, child: categoriesSearchableList())
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
    if (widget.expenditure.title == '' ||
        widget.expenditure.value == 0.0 ||
        widget.expenditure.date == DatabaseHandler.defaultDate ||
        widget.expenditure.category == CategoryDescriptor.Error()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'All fields must be filled ${widget.expenditure.title == '' ? 'Title' : ''} ${widget.expenditure.category == CategoryDescriptor.Error() ? 'Category' : ''} ${widget.expenditure.value == 0.0 ? 'Amount' : ''} ${widget.expenditure.date == DatabaseHandler.defaultDate ? 'Date' : ''}')));
      return false;
    } else {
      await DatabaseHandler().UpdateData(widget.expenditure);
    }
    return true;
  }
}
