import 'package:ledgerstats/Expenses/view/expenditures_list_view.dart';
import 'package:ledgerstats/options_view.dart';
import 'package:ledgerstats/Analytics/view/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:ledgerstats/home.dart';
import 'package:ledgerstats/database_handler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ledgerstats/Categories/view/categories_view.dart';
import 'package:flutter/services.dart';
import 'package:ledgerstats/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHandler databaseHandler = DatabaseHandler();
  await databaseHandler.initializeDatabaseConnexion();
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        theme: ThemeData(
            primarySwatch: MaterialColor(
                AppColors.primaryColor.value, AppColors.primaryColorSwatch)),
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
