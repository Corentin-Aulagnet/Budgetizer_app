import 'package:ledgerstats/Categories/utils/category_utils.dart';
import 'package:ledgerstats/database_handler.dart';
import 'package:flutter/material.dart';
import '../utils/expenditure.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ledgerstats/Expenses/view/add_expenditure_view.dart';

class ExpenditureView extends StatefulWidget {
  int id;
  ExpenditureView({super.key, required this.id});

  @override
  State<ExpenditureView> createState() => ExpenditureViewState();
}

class ExpenditureViewState extends State<ExpenditureView> {
  late Future<Expenditure> _expenseFuture =
      DatabaseHandler().getExpense(widget.id);
  late Expenditure _expense;

  @override
  void initState() {
    super.initState();

    _expenseFuture.then((value) => _expense = value);
  }

  @override
  void didUpdateWidget(ExpenditureView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _expenseFuture = DatabaseHandler().getExpense(widget.id);
    _expenseFuture.then((value) => _expense = value);
  }

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
                        title: Text(
                            'Delete Expense ${_expense.title}'), //TODO localization
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                "Do you really want to delete the expense ${_expense.title}"), //TODO localization
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () async {
                              await DatabaseHandler().deleteExpense(_expense);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Expense deleted"))); //TODO localization
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
                            expenditure: _expense,
                          ))).then((_) {
                setState(() {
                  _expenseFuture = DatabaseHandler().getExpense(widget.id);
                });
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
          title: const Text('View an Expenditure'), //TODO localization
          leading: const BackButton(),
        ),
        body: FutureBuilder<Expenditure>(
            future: _expenseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: const EdgeInsets.only(top: 15),
                          child: Text(
                            snapshot.data!.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          )),
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: Row(children: [
                          Expanded(
                              child: Center(child: Text('${_expense.value}€'))),
                          Expanded(
                              child: Center(
                                  child: Text(
                                      '${_expense.date.day.toString().padLeft(2, '0')}/${_expense.date.month.toString().padLeft(2, '0')}/${_expense.date.year.toString().padLeft(2, '0')}')))
                        ]),
                      ),
                      Expanded(
                          flex: 2,
                          child: CategoryItem(
                            category: snapshot.data!.category,
                            notifyParent: () {},
                            displayBin: false,
                          ))
                    ]);
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasError) {
                return Column(children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ]);
              } else {
                return Column(children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: No Data'),
                  ),
                ]);
              }
            }));
  }
}
