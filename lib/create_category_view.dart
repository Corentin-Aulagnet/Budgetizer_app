import 'package:flutter/material.dart';
import 'package:budgetizer/Categories/utils/category_utils.dart';
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
  late CategoryDescriptor? parentCategory = DatabaseHandler.categoriesList[0];
  bool isSubCategory = false;
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
            title: const Text('Create a category'), //TODO localization
            leading: const BackButton(),
          ),
          body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'category name', //TODO localization
                    labelText: 'Name', //TODO localization
                  ),
                  onChanged: (String? value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                    if (value != null) name = value;
                  },
                  validator: (String? value) {
                    return (value != null)
                        ? 'Do not use the @ char.'
                        : null; //TODO localization
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
                    hintText: 'Select an emoji', //TODO localization
                    labelText: 'Category Emoji', //TODO localization
                  ),
                ),
                Row(children: [
                  Text('is subcategory ?'), //TODO localization
                  Checkbox(
                      value: isSubCategory,
                      onChanged: (bool? value) {
                        setState(() {
                          isSubCategory = value!;
                        });
                      }),
                  DropdownButton<CategoryDescriptor>(
                      //subcategory dropdown
                      value: isSubCategory ? parentCategory : null,
                      disabledHint: Text('None'), //TODO localization
                      onChanged: isSubCategory
                          ? dropDownButtonEnabledOnChangedFunction
                          : null,
                      items: List.generate(
                          DatabaseHandler.categoriesList.length, (index) {
                        CategoryDescriptor cat =
                            DatabaseHandler.categoriesList[index];
                        return DropdownMenuItem(
                            value: cat,
                            child: Text('${cat.emoji} ${cat.name}'));
                      })),
                ]),
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

  dropDownButtonEnabledOnChangedFunction(CategoryDescriptor? value) {
    // This is called when the user selects an item.
    setState(() {
      parentCategory = value!; //Code to run
    });
  }

  Future<bool> addCategory() async {
    //Validates that all mandatory fields are filled
    if (name == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'All fields must be filled ${name == '' ? 'Name' : ''},${emoji == '' ? 'Emoji' : ''}'))); //TODO localization
      return false;
    } else {
      CategoryDescriptor categoryToAdd = isSubCategory
          ? CategoryDescriptor.childrenOf(
              name: name,
              emoji: emoji,
              descriptors: [],
              id: 0,
              parent: parentCategory!)
          : CategoryDescriptor(
              id: 0,
              emoji: emoji,
              name: name,
              descriptors: [],
            );
      await DatabaseHandler().saveCategory(categoryToAdd);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Category added"))); //TODO localization
    }
    return true;
  }
}
