import 'package:budgetizer/expenditures_list_view.dart';
import 'package:budgetizer/options_view.dart';
import 'package:budgetizer/Analytics/view/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:budgetizer/home.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetizer/Categories/view/categories_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHandler databaseHandler = DatabaseHandler();
  await databaseHandler.initializeDatabaseConnexion();
  Bloc.observer = SimpleBlocObserver();
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
          '/Categories': (context) => CategoriesView(),
          '/Options': (context) => OptionsView(),
        });
    //home: Home());
  }
}

/// Custom [BlocObserver] which observes all bloc and cubit instances.
class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}
