import 'package:budgetizer/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryDescriptor {
  late String emoji;
  late String name;
  late List<String> descriptors;
  late int id;
  late bool isError;
  CategoryDescriptor? parent;
  Set<CategoryDescriptor> children = {};

  CategoryDescriptor({
    required this.name,
    required this.emoji,
    required this.descriptors,
    required this.id,
  }) {
    isError = false;
  }

  CategoryDescriptor.childrenOf(
      {required this.name,
      required this.emoji,
      required this.descriptors,
      required this.id,
      required CategoryDescriptor this.parent}) {
    isError = false;
    parent!.addChild(this);
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

  void addChild(CategoryDescriptor child) {
    children.add(child);
  }

  void makeChildOf(CategoryDescriptor parent) {
    this.parent = parent;
  }

  String display() {
    return name;
  }

  String getName(BuildContext context) {
    return isError ? AppLocalizations.of(context)!.noCategoryName : name;
  }

  bool isCluster() {
    //Is a cluster if has children or if no parent and no children
    return children.isNotEmpty || children.isEmpty && parent == null;
  }

  bool isChild() {
    //Is a child if has a parent
    return parent != null;
  }

  bool isOrphan() {
    //is Orphan if no parent and no children
    return children.isEmpty && parent == null;
  }

  @override
  int get hashCode => id;
  @override
  bool operator ==(Object other) {
    return other is CategoryDescriptor && other.hashCode == hashCode;
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
                  category.parent == null
                      ? ''
                      : 'Child of ${category.parent!.emoji} ${category.parent!.name}',
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
              showDeleteDialog(context, category, notifyParent);
            },
            icon: const Icon(
              Icons.delete,
              color: Color(0xffff0000),
            ))
        : const Spacer();
  }
}

void showDeleteDialog(
    BuildContext context, CategoryDescriptor category, Function() callback) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text('Delete Category ${category.name}'), //TODO localization
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(AppLocalizations.of(context)!
                    .categoryDeleteConfirmationMessage(category.name)),
                Text(AppLocalizations.of(context)!
                    .categoryDeleteConfimationMessageUses(
                        DatabaseHandler.countExpensesInCategory(category)))
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  //if has children put null as parent for each one of them
                  for (CategoryDescriptor child in category.children) {
                    child.parent = null;
                  }
                  //Update database
                  await DatabaseHandler()
                      .updateCategories(category.children.toList());
                  await DatabaseHandler().deleteCategory(category);
                  callback();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Category deleted"))); //TODO localization
                },
                child: const Text(
                  'Delete', //TODO localization
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
}
