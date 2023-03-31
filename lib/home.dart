import 'Analytics/utils/charts.dart';
import 'package:budgetizer/Analytics/blocs/analytics_bloc.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'Expenses/view/add_expenditure_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app_colors.dart';
import 'navigation_drawer.dart';

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
              drawer: AppNavigationDrawer(),
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
                          builder: (context) => AddExpenditureView())).then(
                      (_) => setState(() {})); //TODO Add a Bloc for expenses
                },
                backgroundColor: AppColors.secondaryColor,
                child: const Icon(Icons.add),
              ),
              body: Column(
                children: [
                  Center(
                      child: Text(
                    AppLocalizations.of(context)!
                        .welcomeUser("Test User"), //TODO localization
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  )),
                  Center(
                      child: Text(
                    AppLocalizations.of(context)!
                        .monthPreview(DateTime.now()), //TODO localization
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  )),
                  MonthlyPie(
                    alignment: Axis.horizontal,
                  ),
                  ListTile(
                    leading: Text(
                        DatabaseHandler.expendituresList[0].category.emoji),
                    title: Text(
                        '${DatabaseHandler.expendituresList[0].title} | ${DatabaseHandler.expendituresList[0].category.getName(context)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(DatabaseHandler.expendituresList[0].date)} ${DatabaseHandler.expendituresList[0].value.toString()}€'),
                  ),
                  ListTile(
                    title: Text(
                        '${DatabaseHandler.expendituresList[1].title} | ${DatabaseHandler.expendituresList[1].category.getName(context)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    leading: Text(
                        DatabaseHandler.expendituresList[1].category.emoji),
                    subtitle: Text(
                        '${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(DatabaseHandler.expendituresList[1].date)} ${DatabaseHandler.expendituresList[1].value.toString()}€'),
                  ),
                ],
              )));
    } else {
      return Scaffold(
        drawer: AppNavigationDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.welcomeMessage),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddExpenditureView()))
                .then((_) => setState(() {})); //TODO Add a Bloc for expenses
          },
          backgroundColor: AppColors.secondaryColor,
          child: const Icon(Icons.add),
        ),
        body: null,
      );
    }
  }
}
