import 'package:flutter/material.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:budgetizer/Icons Selector/IconListTile.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:budgetizer/database_handler.dart';

class CreateCategoryView extends StatefulWidget {
  const CreateCategoryView({super.key});
  @override
  State<CreateCategoryView> createState() => _CreateCategoryView();
}

class _CreateCategoryView extends State<CreateCategoryView> {
  late IconDescriptor icon = icons[0];
  late String name;
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  static List<IconDescriptor> icons = [
    IconDescriptor(
        icon: Icons.abc, name: "abc", descriptors: ["alphabet", "a", "b", "c"]),
    IconDescriptor(
        icon: Icons.account_balance,
        name: "bank",
        descriptors: ["building", "bank", "account"]),
    IconDescriptor(
        icon: Icons.food_bank,
        name: "food bank",
        descriptors: ["food", "bank", "building"]),
    IconDescriptor(
        icon: Icons.apple_outlined,
        name: "apple",
        descriptors: ["apple", "iphone"]),
  ];
  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
            // Use Material color picker:
            //
            // child: MaterialPicker(
            //   pickerColor: pickerColor,
            //   onColorChanged: changeColor,
            //   showLabel: true, // only on portrait mode
            // ),
            //
            // Use Block color picker:
            //
            // child: BlockPicker(
            //   pickerColor: currentColor,
            //   onColorChanged: changeColor,
            // ),
            //
            // child: MultipleChoiceBlockPicker(
            //   pickerColors: currentColors,
            //   onColorsChanged: changeColors,
            // ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          //called when the body of the screen is touched
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Create a category'),
            leading: const BackButton(),
          ),
          body: Column(children: <Widget>[
            Expanded(
                //flex: 2,
                child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'category name',
                labelText: 'Name',
              ),
              onChanged: (String? value) {
                // This optional block of code can be used to run
                // code when the user saves the form.
                if (value != null) name = value;
              },
              validator: (String? value) {
                return (value != null) ? 'Do not use the @ char.' : null;
              },
            )),
            Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text("Selected Icon"),
                  Icon(icon.icon, color: currentColor, size: 45),
                  ColoredBox(
                    color: currentColor,
                    child: TextButton(
                      child: Text(''),
                      onPressed: () => _dialogBuilder(context),
                    ),
                  )
                ])),
            Expanded(
                flex: 10,
                child: SearchableList<IconDescriptor>(
                    initialList: icons,
                    filter: (value) => icons
                        .where(
                          (element) =>
                              element.name.toLowerCase().contains(value) ||
                              element.descriptors.join('').contains(value),
                        )
                        .toList(),
                    builder: (IconDescriptor icon) =>
                        IconItem(icon: icon, color: currentColor),
                    inputDecoration: InputDecoration(
                      labelText: "Search Icon",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onItemSelected: (IconDescriptor icon) {
                      setState(() {
                        this.icon = icon;
                      });
                    }))
          ]),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                AddCategory();
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.save)),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ));
  }

  Future<bool> AddCategory() async {
    //Validates that all mandatory fields are filled
    if (name == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('All fields must be filled ${name == '' ? 'Name' : ''} ')));
      return false;
    } else {
      icon.color = currentColor;
      await DatabaseHandler.SaveCategory(CategoryDescriptor(
          icon: icon.icon,
          name: name,
          descriptors: icon.descriptors,
          color: currentColor));
      await DatabaseHandler.LoadCategories();
      print(
          '${icon.icon.codePoint} ${icon.icon.fontFamily} ${icon.icon.fontPackage}');
    }
    return true;
  }
}
