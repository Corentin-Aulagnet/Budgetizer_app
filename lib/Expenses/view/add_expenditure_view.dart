import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ledgerstats/Categories/utils/category_utils.dart';
import 'package:ledgerstats/Expenses/blocs/expense_bloc.dart';
import 'package:provider/provider.dart';
import 'package:ledgerstats/database_handler.dart';
import 'package:ledgerstats/Expenses/utils/expenditure.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:ledgerstats/Categories/view/create_category_view.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app_colors.dart';

class AddExpenditureView extends StatefulWidget {
  AddExpenditureView({super.key, Expenditure? expenditure}) {
    if (expenditure == null) {
      this.expenditure = Expenditure.dummy();
      isModifying = false;
    } else {
      this.expenditure = Expenditure.copy(expenditure);
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
        return (value != null)
            ? 'Do not use the @ char.'
            : null; //TODO localization
      },
    );
  }

  Widget amountFieldForm() {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'amount', //TODO localization
        labelText: 'Amount', //TODO localization
      ),
      initialValue: widget.expenditure.value.isNaN
          ? ''
          : widget.expenditure.value.toString(),
      onChanged: (String? value) {
        // This optional block of code can be used to run
        // code when the user saves the form.
        if (value != null)
          {
            widget.expenditure.value = value != '' ? double.parse(value) : 0.0;
          }
      },
      validator: (String? value) {
        return (value != null &&
                value.contains(RegExp('[a-zA-Z&é"\'()\-è`_\\ç^à@\[\]=+{}]+')))
            ? 'Use only numbers' //TODO localization
            : null;
      },
    );
  }

  Widget categoriesSearchableList() {
    return SearchableList<CategoryDescriptor>(
        key: UniqueKey(),
        //only keep the categories that don't have children -> child category or orphan
        //Clusters should not be accessible as a base category
        initialList: List<CategoryDescriptor>.from(DatabaseHandler
                .categoriesList
                .where((element) => element.children.isEmpty)) +
            [
              CategoryDescriptor(
                id: 0,
                emoji: '\u2795',
                name: "Create a category", //TODO localization
                descriptors: [""],
              )
            ],
        filter: (value) =>
            List<CategoryDescriptor>.from(DatabaseHandler.categoriesList.where(
              (element) =>
                  element.getName(context).toLowerCase().contains(value),
            )),
        builder: (List<CategoryDescriptor> list, int num,
            CategoryDescriptor category) {
          if (category.getName(context) == "Create a category") {
            //TODO localization
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
          labelText: "Search Category", //TODO localization
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColors.primaryColor,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onItemSelected: (CategoryDescriptor category) {
          if (category.getName(context) == "Create a category") {
            //TODO localization
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
        },
        closeKeyboardWhenScrolling: true);
  }
  @override
  Widget build(BuildContext context) {
    //DatabaseHandler().loadCategories();
    DateTime? selectedDate;
    return GestureDetector(
        onTap: () {
          //called when the body of the screen is touched
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: BlocListener<ExpenseBloc, ExpenseState>(
  listener: (context, state) {
    if(state is ExpensesLoaded){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.isModifying
              ? "Expense updated"
              : "Expense added")));
    }
  },
  child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(widget.isModifying
                ? AppLocalizations.of(context)!.modifyExpenseTitle
                : AppLocalizations.of(context)!.addExpenseTitle),
            leading: const BackButton(),
          ),
          body: Column(children: <Widget>[
            titleFieldForm(),
            Row(children: [
              const Text("Category Selected"), //TODO localization
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
                child:DateTimeFormField(
                  mode: DateTimeFieldPickerMode.date,
                  decoration: const InputDecoration(
                    labelText: 'Enter Date',
                  ),
                  firstDate: DateTime.now().add(const Duration(days: -365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialPickerDateTime: widget.expenditure.date,
                  onChanged: (DateTime? value) {
                    selectedDate = value;
                    if(value != null) widget.expenditure.date = value;
                  },
                ),
              )
            ]),
            Expanded(flex: 10, child: categoriesSearchableList())
          ]),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                bool added = false;
                if (widget.expenditure.title == '' ||
                    widget.expenditure.value == double.nan ||
                    widget.expenditure.category == CategoryDescriptor.error()) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'All fields must be filled ${widget.expenditure.title == '' ? 'Title' : ''} ${widget.expenditure.category == CategoryDescriptor.error() ? 'Category' : ''} ${widget.expenditure.value == 0.0 ? 'Amount' : ''} ${selectedDate == null ? 'Date' : ''}'))); //TODO localization
                } else {
                  //added = await DatabaseHandler().updateData(widget.expenditure);
                  context.read<ExpenseBloc>().add(
                      AddExpense(expense: widget.expenditure));
                  Navigator.of(context).pop();
                }
              },
              child: const Icon(Icons.save)),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
));
  }

  refresh() async {
    //await DatabaseHandler().loadCategories();
    setState(() {});
  }

  Future<bool> addExpenditureToDatabase() async {
    //Validates that all mandatory fields are filled
    if (widget.expenditure.title == '' ||
        widget.expenditure.value == 0.0 ||
        widget.expenditure.date == DatabaseHandler.defaultDate ||
        widget.expenditure.category == CategoryDescriptor.error()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${DatabaseHandler.defaultDate} All fields must be filled ${widget.expenditure.title == '' ? 'Title' : ''} ${widget.expenditure.category == CategoryDescriptor.error() ? 'Category' : ''} ${widget.expenditure.value == 0.0 ? 'Amount' : ''} ${widget.expenditure.date == DatabaseHandler.defaultDate ? 'Date' : ''}'))); //TODO localization
      return false;
    } else {
      await DatabaseHandler().updateData(widget.expenditure);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.isModifying
              ? "Expense updated"
              : "Expense added"))); //TODO localization
    }
    return true;
  }
}
