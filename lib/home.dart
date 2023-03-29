import 'package:budgetizer/charts.dart';
import 'package:budgetizer/Analytics/blocs/analytics_bloc.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_expenditure_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app_colors.dart';

class AddExpenditureFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        //We need a bloc for the expenditureList view to refresh only this widget after a expenditure has been added
        // Add your onPressed code here!
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddExpenditureView()));
      },
      backgroundColor: AppColors.secondaryColor,
      child: const Icon(Icons.add),
    );
  }
}

class Home extends StatefulWidget {
  static Drawer appNavigationDrawer(context) {
    return Drawer(
        child: Column(
      children: [
        const UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: AppColors.primaryColor),
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
            title: const Text("Home"), //TODO Localization
            onTap: () => Navigator.popAndPushNamed(context, '/')),
        ListTile(
            leading: Icon(Icons.format_list_bulleted_rounded),
            title: const Text("Expenses"), //TODO localization
            onTap: () => Navigator.popAndPushNamed(context, '/Expenses')),
        ListTile(
            leading: Icon(Icons.auto_graph),
            title: const Text("Analytics"), //TODO localization
            onTap: () => Navigator.popAndPushNamed(context, '/Analytics')),
        ListTile(
            leading: Icon(Icons.category_rounded),
            title: const Text("Categories"), //TODO localization
            onTap: () => Navigator.popAndPushNamed(context, '/Categories')),
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

  Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    if (DatabaseHandler.expendituresList.isNotEmpty) {
      return BlocProvider(
          create: (_) => PieChartBloc.unique(
              showAllCategories: false,
              chartType: ChartsType.monthlyPie,
              month: [DateTime.now().month.toString()],
              year: [DateTime.now().year.toString()]),
          child: Scaffold(
              drawer: Home.appNavigationDrawer(context),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.welcomeMessage),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  //We need a bloc for the expenditureList view to refresh only this widget after a expenditure has been added
                  // Add your onPressed code here!
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddExpenditureView()))
                      .then((_) => setState(() {}));
                },
                backgroundColor: AppColors.secondaryColor,
                child: const Icon(Icons.add),
              ),
              body: Column(
                children: [
                  Center(
                      child: Text(
                    "Votre mois de ${DateTime.now().month.toString()} ${DateTime.now().year.toString()}", //TODO localization
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  )),
                  MonthlyPie()
                ],
              )));
    } else {
      return Scaffold(
        drawer: Home.appNavigationDrawer(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.welcomeMessage),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //We need a bloc for the expenditureList view to refresh only this widget after a expenditure has been added
            // Add your onPressed code here!
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddExpenditureView()));
          },
          backgroundColor: AppColors.secondaryColor,
          child: const Icon(Icons.add),
        ),
        body: null,
      );
    }
  }
}
