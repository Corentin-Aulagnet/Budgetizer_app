import 'package:ledgerstats/Categories/utils/category_utils.dart';
import 'package:ledgerstats/Expenses/blocs/expenses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ledgerstats/database_handler.dart';
import 'package:date_field/date_field.dart';
class FilterPanel extends StatefulWidget {
  List<bool> checkedCategories;
  List<CategoryDescriptor> categories;
  DateTime? fromDate;
  DateTime? toDate;
  AnimationController controller;
  Animation<double> animation;
  FilterPanel(ExpenseFilterBloc bloc,
      {required this.checkedCategories,
      required this.categories,
      required this.controller,
      required this.animation}) {
    fromDate = bloc.fromDate;
    toDate = bloc.toDate;
  }

  @override
  FilterPanelState createState() => FilterPanelState();
}

class FilterPanelState extends State<FilterPanel>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
        alignment: Alignment.topRight,
        scale: widget.animation,
        child: SizedBox(
            height: 450,
            width: 300,
            child: Card(
                child: Column(children: [
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        BlocProvider.of<ExpenseFilterBloc>(context).add(
                            AddAllToFilter(
                                categories: List.from(widget.categories)));
                        setState(() {
                          widget.checkedCategories =
                              List.filled(widget.categories.length, true);
                        });
                      },
                      child: Text("Select all")), //TODO localization
                  TextButton(
                      onPressed: () {
                        BlocProvider.of<ExpenseFilterBloc>(context)
                            .add(RemoveAllFromFilter());
                        setState(() {
                          widget.checkedCategories =
                              List.filled(widget.categories.length, false);
                        });
                      },
                      child: Text("Deselect all")) //TODO localization
                ],
              ),
              Container(
                  height: 250,
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: widget.categories.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: widget.checkedCategories[index],
                        onChanged: (bool? value) {
                          if (value!) {
                            BlocProvider.of<ExpenseFilterBloc>(context).add(
                                AddToFilter(
                                    category: widget.categories[index]));
                          } else {
                            BlocProvider.of<ExpenseFilterBloc>(context).add(
                                RemoveFromFilter(
                                    category: widget.categories[index]));
                          }
                          setState(() {
                            widget.checkedCategories[index] = value;
                          });
                        },
                        title: Text(
                            '${widget.categories[index].emoji}${widget.categories[index].name}'),
                      );
                    },
                  )),
              Divider(),
              Column(children: [
                Row(
                  children: [
                    Text('from'), //TODO localization
                    Expanded(
                        child: DateTimeFormField(
                          mode: DateTimeFieldPickerMode.date,
                          decoration: const InputDecoration(
                            labelText: 'Enter Date',
                          ),
                          firstDate: DateTime(1900,01,01),
                          lastDate: DateTime(2100,12,31),
                          initialPickerDateTime: DateTime.now(),
                          onChanged: (DateTime? value) {
                            //selectedDate = value;
                          },
                        ),),
                  ],
                ),
                Row(
                  children: [
                    Text('to'), //TODO localization
                    Expanded(
                        child: DateTimeFormField(
                          mode: DateTimeFieldPickerMode.date,
                          decoration: const InputDecoration(
                            labelText: 'Enter Date',
                          ),
                          firstDate: DateTime(1900,01,01),
                          lastDate: DateTime(2100,12,31),
                          initialPickerDateTime: DateTime.now(),
                          onChanged: (DateTime? value) {
                            //selectedDate = value;
                          },
                        ),),
                  ],
                )
              ])
            ]))));
  }
}
