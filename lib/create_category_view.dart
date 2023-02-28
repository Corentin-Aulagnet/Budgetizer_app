import 'package:flutter/material.dart';
import 'package:budgetizer/Icons_Selector/category_utils.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:flutter/services.dart';

class CreateCategoryView extends StatefulWidget {
  const CreateCategoryView({super.key});
  @override
  State<CreateCategoryView> createState() => _CreateCategoryView();
}

class _CreateCategoryView extends State<CreateCategoryView> {
  late String name = '';
  late String emoji = '';
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
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
            TextFormField(
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
            ),
            TextFormField(
              controller: _controller,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(
                      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'),
                )
              ],
              onChanged: (String? value) {
                // This optional block of code can be used to run
                // code when the user saves the form.
                if (value != null) emoji = value;
              },
              decoration: const InputDecoration(
                hintText: 'Select an emoji',
                labelText: 'Category Emoji',
              ),
            ),
          ]),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (await addCategory()) Navigator.of(context).pop();
              },
              child: const Icon(Icons.save)),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ));
  }

  Future<bool> addCategory() async {
    //Validates that all mandatory fields are filled
    if (name == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'All fields must be filled ${name == '' ? 'Name' : ''},${emoji == '' ? 'Emoji' : ''}')));
      return false;
    } else {
      await DatabaseHandler().saveCategory(CategoryDescriptor(
        id: 0,
        emoji: emoji,
        name: name,
        descriptors: [],
      ));
    }
    return true;
  }
}
