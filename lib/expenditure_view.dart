import 'package:budgetizer/Icons%20Selector/IconListTile.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:flutter/material.dart';
import 'expenditure.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:budgetizer/add_expenditure_view.dart';

class ExpenditureView extends StatefulWidget {
  Expenditure expenditure;

  ExpenditureView({super.key, required this.expenditure});

  @override
  State<ExpenditureView> createState() => ExpenditureViewState();
}

class ExpenditureViewState extends State<ExpenditureView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title:
                            Text('Delete Expense ${widget.expenditure.title}'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                "Do you really want to delete the expense ${widget.expenditure.title}"),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () async {
                              await DatabaseHandler()
                                  .DeleteExpense(widget.expenditure);
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
            heroTag: "deleteFAB",
            backgroundColor: const Color(0xffff0000),
            child: const Icon(Icons.delete),
          ),
          FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddExpenditureView(
                            expenditure: widget.expenditure,
                          ))).then((_) async {
                await DatabaseHandler.fetchData();
                findExpenditureDisplayed();
                setState(() {});
              });
            },
            heroTag: "modifyFAB",
            child: const Icon(
              MdiIcons.pencil,
            ),
          ),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title: const Text('View an Expenditure'),
          leading: const BackButton(),
        ),
        body: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: Text(
                    widget.expenditure.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 25),
                  )),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Row(children: [
                  Expanded(
                      child:
                          Center(child: Text('${widget.expenditure.value}???'))),
                  Expanded(
                      child: Center(
                          child: Text(
                              '${widget.expenditure.date.day.toString().padLeft(2, '0')}/${widget.expenditure.date.month.toString().padLeft(2, '0')}/${widget.expenditure.date.year.toString().padLeft(2, '0')}')))
                ]),
              ),
              Expanded(
                  flex: 2,
                  child: CategoryItem(
                    category: widget.expenditure.category,
                    color: widget.expenditure.category.color,
                    notifyParent: () {},
                    displayBin: false,
                  ))
            ]));
  }

  void findExpenditureDisplayed() {
    for (var exp in DatabaseHandler.expendituresList) {
      if (exp.dataBaseId == widget.expenditure.dataBaseId) {
        //found it!
        widget.expenditure = exp;
      }
    }
  }
}
