import 'package:flutter/material.dart';
import 'package:budgetizer/options_view.dart';
import 'expenditures_list_view.dart';
import 'add_expenditure_view.dart';

class Home extends StatelessWidget {
  Home({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeWidget();
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});
  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Builder(
        builder: (context) => DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                  bottom: const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.table_rows)),
                      Tab(icon: Icon(Icons.auto_graph)),
                    ],
                  ),
                  title: const Text('Welcome to Flutter'),
                  actions: <Widget>[
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OptionsView()),
                          );
                        },
                        icon: const Icon(Icons.menu))
                  ]),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Add your onPressed code here!
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddExpenditureView()),
                  ).then((_) => setState(() {}));
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.add),
              ),
              body: TabBarView(
                children: [
                  ExpenditureTab(),
                  const Icon(Icons.auto_graph),
                ],
              ),
            )),
      ),
    );
  }
}
