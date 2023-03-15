import 'package:budgetizer/charts.dart';
import 'package:budgetizer/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_expenditure_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//const int primaryColor = 0xffed4423;
const Color primaryColor = Color.fromRGBO(237, 68, 35, 1);
const Color secondaryColor = Color.fromRGBO(204, 204, 204, 1);
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

class Home extends StatefulWidget {
  static Drawer appNavigationDrawer(context) {
    return Drawer(
        child: Column(
      children: [
        const UserAccountsDrawerHeader(
          // <-- SEE HERE
          decoration: BoxDecoration(color: primaryColor),
          accountName: Text(
            "Test User",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          accountEmail: Text(
            "abcd.efgh@domain.com",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          currentAccountPicture: FlutterLogo(),
        ),
        ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.popAndPushNamed(context, '/')),
        ListTile(
            leading: Icon(Icons.format_list_bulleted_rounded),
            title: const Text("Expenses"),
            onTap: () => Navigator.popAndPushNamed(context, '/Expenses')),
        ListTile(
            leading: Icon(Icons.auto_graph),
            title: const Text("Analytics"),
            onTap: () => Navigator.popAndPushNamed(context, '/Analytics')),

        Spacer(), // <-- This will fill up any free-space
        // Everything from here down is bottom aligned in the drawer
        Divider(),
        ListTile(
            leading: Icon(Icons.settings),
            title: const Text("Options"),
            onTap: () => Navigator.popAndPushNamed(context, '/Options')),
      ],
    ));
  }

  static FloatingActionButton addExpenditureFloatingActionButton(context) {
    return FloatingActionButton(
      onPressed: () {
        // Add your onPressed code here!
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddExpenditureView()));
      },
      backgroundColor: secondaryColor,
      child: const Icon(Icons.add),
    );
  }

  Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => ChartBloc.unique(
            chartType: PieType.monthly,
            month: DateTime.now().month.toString(),
            year: DateTime.now().year.toString()),
        child: Scaffold(
            drawer: Home.appNavigationDrawer(context),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.welcomeMessage),
            ),
            floatingActionButton:
                Home.addExpenditureFloatingActionButton(context),
            body: Column(
              children: [
                Center(
                    child: Text(
                  "Votre mois de ${DateTime.now().month.toString()} ${DateTime.now().year.toString()}",
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                )),
                CategoryPie()
              ],
            )));
  }
}
