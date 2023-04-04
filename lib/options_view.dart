import 'package:ledgerstats/database_handler.dart';
import 'package:flutter/material.dart';

class OptionsView extends StatefulWidget {
  const OptionsView({super.key});
  @override
  State<OptionsView> createState() => _OptionsViewState();
}

class _OptionsViewState extends State<OptionsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Options'),
          leading: const BackButton(),
        ),
        body: Center(
            child: Column(children: [
          TextButton(
              child: const Text('Regenerate Database'),
              onPressed: () {
                DatabaseHandler().regenerateDatabase();
              }),
          TextButton(
              child: const Text('Reset Categories'),
              onPressed: () {
                DatabaseHandler().deleteCategories();
              })
        ])));
  }
}
