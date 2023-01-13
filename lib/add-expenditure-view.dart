import 'package:flutter/material.dart';
import 'drop-down-button.dart';
class AddExpenditureView extends StatefulWidget{
  const AddExpenditureView({super.key});
  @override
  State<AddExpenditureView> createState () => _AddExpenditureViewState();
}
class _AddExpenditureViewState extends State<AddExpenditureView>{
  String title = '';
  double value = 0.0;
  String currencySelected= 'Eur';
  _AddExpenditureViewState();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Expenditure'),
        leading: const BackButton(),
      ),
      body :Column(
          children: <Widget>[
            Row(
              children:<Widget>[
                const Expanded(
                  child: Text('title'),
                ),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter an title',
                    ),
                    onSubmitted: (String value) =>{title = value},
                  ),
                ),
              ],
            ),
            Row(
              children:<Widget>[
                const Expanded(
                  child: Text('value'),
                ),
                Expanded(
                  flex:3,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter an value',
                    ),
                    onSubmitted: (String value) =>{this.value = double.parse(value)},
                  ),
                ),
                Expanded(
                  child: DropdownButton<String>(
                    value: currencySelected,
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {currencySelected = value!;//Code to run
                      });
                    },
                    items:<DropdownMenuItem<String>>[DropdownMenuItem(value : 'Eur',child: Text('Eur')),
                                                          DropdownMenuItem(value : '\$US',child: Text('\$US'))],
                  ),
                )
              ],
            ),
          ]
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 50.0),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          //Define what to do when pressed
        }),
        child: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}