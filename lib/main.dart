import 'package:ledgerstats/Expenses/blocs/expense_bloc.dart';
import 'package:ledgerstats/Expenses/view/add_expenditure_view.dart';
import 'package:ledgerstats/Expenses/view/expenditure_view.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ExpenseBloc()
            ..add(
              LoadExpenses(),
            ),
        ),
      ],
      child: MaterialApp(
          theme: ThemeData(
              primarySwatch: MaterialColor(
                  AppColors.primaryColor.value, AppColors.primaryColorSwatch)),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('fr'), // French
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => Home(),
            '/Expenses': (context) => Expenditures(),
            '/Analytics': (context) => StatisticsView(),
            '/Categories': (context) => CategoriesView(),
            '/Options': (context) => const OptionsView(),
          }),
    );
  }
}

class SimpleView extends StatelessWidget {
  const SimpleView();

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Simple View"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (ctx) => AddExpenditureView(),
                    ));
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: BlocBuilder<ExpenseBloc, ExpenseState>(builder: (context, state) {
          if (state is ExpensesLoading) {
            return const CircularProgressIndicator();
          }
          if(state is ExpensesLoaded){
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        "Pending To Dos: ",
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.expenses.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                            title: Text(
                                '${state.expenses[index].title}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)));
                      },
                    )
                  ]));}
          else{
            return const Text("Someting went wrong");
          }
        }));
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
