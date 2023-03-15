import 'package:budgetizer/expenditures_list_view.dart';
import 'package:budgetizer/options_view.dart';
import 'package:budgetizer/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:budgetizer/home.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHandler databaseHandler = DatabaseHandler();
  await databaseHandler.initializeDatabaseConnexion();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            primarySwatch:
                MaterialColor(primaryColor.value, primaryColorSwatch)),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'), // English
          Locale('fr'), // French
        ],
        initialRoute: '/',
        routes: {
          '/': (context) => Home(),
          '/Expenses': (context) => Expenditures(),
          '/Analytics': (context) => StatisticsView(),
          '/Options': (context) => OptionsView(),
        });
    //home: Home());
  }
}
