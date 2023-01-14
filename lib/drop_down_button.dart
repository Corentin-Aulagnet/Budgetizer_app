import 'package:flutter/material.dart';
class MyDropdownButton extends StatefulWidget {
  List<String> list = <String>['Eur', '\$US'];
  MyDropdownButton({super.key, required list});

  @override
  State<MyDropdownButton> createState() => _MyDropdownButtonState(list : list);
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  List<String> list = <String>['Eur', '\$US'];
  String dropdownValue = 'Eur';
  _MyDropdownButtonState({required list}){
    dropdownValue = list.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}