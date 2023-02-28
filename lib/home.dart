import 'package:budgetizer/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:budgetizer/options_view.dart';
import 'expenditures_list_view.dart';
import 'add_expenditure_view.dart';

const int primaryColor = 0xffed4423;
const int secondaryColor = 0xffcccccc;
Map<int, Color> primaryColorSwatch = {
  50: const Color.fromRGBO(239, 68, 35, 0.1),
  100: const Color.fromRGBO(239, 68, 35, 0.2),
  200: const Color.fromRGBO(239, 68, 35, 0.3),
  300: const Color.fromRGBO(239, 68, 35, 0.4),
  400: const Color.fromRGBO(239, 68, 35, 0.5),
  500: const Color.fromRGBO(239, 68, 35, 0.6),
  600: const Color.fromRGBO(239, 68, 35, 0.7),
  700: const Color.fromRGBO(239, 68, 35, 0.8),
  800: const Color.fromRGBO(239, 68, 35, 0.9),
  900: const Color.fromRGBO(239, 68, 35, 1),
};

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
      theme: ThemeData(
          primarySwatch: MaterialColor(primaryColor, primaryColorSwatch)),
      title: 'Welcome to LedgerStats',
      home: Builder(
        builder: (context) => DefaultTabController(
            length: 2,
            child: Scaffold(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: const BottomAppBar(
                  shape: CircularNotchedRectangle(),
                  color: Color(primaryColor),
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
                backgroundColor: const Color(secondaryColor),
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
