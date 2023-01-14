import 'package:flutter/material.dart';
import 'package:budgetizer/home.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHandler.InitializeDatabaseConnexion();
  initializeDateFormatting('fr_FR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Home();
  }
}
