import 'package:budgetizer/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryDescriptor {
  late String emoji;
  late String name;
  late List<String> descriptors;
  late int id;
  late bool isError;
  CategoryDescriptor({
    required this.name,
    required this.emoji,
    required this.descriptors,
    required this.id,
  }) {
    isError = false;
  }
  CategoryDescriptor.error() {
    id = -1;
    name = "error";
    descriptors = [""];
    emoji = '\u26A0';
    isError = true;
  }

  @override
  String toString() {
    return '{id: $id, emoji : $emoji, name : $name, desc : ${descriptors.join('-')}}';
  }

  String display() {
    return name;
  }

  String getName(BuildContext context) {
    return isError ? AppLocalizations.of(context)!.noCategoryName : name;
  }
}

class CategoryItem extends StatelessWidget {
  final Function() notifyParent;
  final CategoryDescriptor category;
  final bool displayBin;
  const CategoryItem(
      {Key? key,
      required this.category,
      required this.notifyParent,
      this.displayBin = true})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Text(category.emoji),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  category.descriptors.join('-'),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Spacer(),
            buildBinButton(context, category)
          ],
        ),
      ),
    );
  }

  StatelessWidget buildBinButton(
      BuildContext context, CategoryDescriptor category) {
    return displayBin
        ? IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: Text('Delete Category ${category.name}'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(AppLocalizations.of(context)!
                                .categoryDeleteConfirmationMessage(
                                    category.name)),
                            Text(AppLocalizations.of(context)!
                                .categoryDeleteConfimationMessageUses(
                                    DatabaseHandler.countExpensesInCategory(
                                            category)
                                        .toString()))
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () async {
                              await DatabaseHandler().deleteCategory(category);
                              await notifyParent();
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Color(0xffff0000)),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ));
            },
            icon: const Icon(
              Icons.delete,
              color: Color(0xffff0000),
            ))
        : const Spacer();
  }
}