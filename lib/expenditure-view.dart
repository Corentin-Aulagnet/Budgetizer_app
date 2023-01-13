import 'package:flutter/material.dart';
import 'expenditure.dart';
class ExpenditureView extends StatelessWidget{
  final Expenditure expenditure;
  //String object;
  //double value;
  const ExpenditureView({super.key, required this.expenditure});
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          title: const Text('View an Expenditure'),
          leading: BackButton(),
        ),
        body : Center(
          child:ListView(
              children:[
                ListTile(
                  title: Text(expenditure.title),
                  trailing: Text(expenditure.value.toString()),
                )
              ]
          ),
        )
    );
  }
}