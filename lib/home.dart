import 'package:budgetizer/database_handler.dart';
import 'package:budgetizer/expenditure.dart';
import 'package:budgetizer/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:budgetizer/options_view.dart';
import 'expenditures_list_view.dart';
import 'add_expenditure_view.dart';

class Home extends StatelessWidget {
  Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeWidget();
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
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: const BottomAppBar(
                  shape: CircularNotchedRectangle(),
                  color: Colors.blue,
                  child: TabBar(tabs: [
                    Tab(icon: Icon(Icons.format_list_bulleted_rounded)),
                    Tab(icon: Icon(Icons.auto_graph)),
                  ])),
              appBar: AppBar(
                  title: const Text('Welcome to Flutter'),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Options',
                      onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OptionsView()))
                            .then((_) => setState(() {}));
                      },
                    )
                  ]),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Add your onPressed code here!
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddExpenditureView()))
                      .then((_) => setState(() {}));
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.add),
              ),
              body: TabBarView(
                children: [
                  ExpendituresListView(),
                  StatisticsView(),
                ],
              ),
            )),
      ),
    );
  }
}
