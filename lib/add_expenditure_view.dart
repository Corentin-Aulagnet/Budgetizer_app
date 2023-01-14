import 'package:budgetizer/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Expenditure'),
        leading: const BackButton(),
      ),
      body: GestureDetector(
        onTap: () {
          //called when the body of the screen is touched
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Column(children: <Widget>[
          Row(children: [
            Expanded(
                child: TextFormField(
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
                          value.contains(
                              RegExp('[a-zA-Z&é\"\'()-è`_\\ç^à@\[\]=+\{\}]+')))
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
          ])
        ]),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 50.0),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          bool added = AddExpenditureToDatabase();
          if (added) Navigator.maybePop(context);
          //Define what to do when pressed
        }),
        child: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  bool AddExpenditureToDatabase() {
    //Validates that all mandatory fields are filled
    if (title_text == '' || value == 0.0 || date == DateTime(1800, 1, 1)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'All fields must be filled ${title_text == '' ? 'Title' : ''} ${value == 0.0 ? 'Amount' : ''}')));
      return false;
    } else {
      DatabaseHandler.InsertData({
        'title': title_text,
        'value': value,
        'date': date.toIso8601String()
      });
      return true;
    }
  }
}
