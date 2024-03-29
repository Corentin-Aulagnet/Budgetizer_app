import 'package:ledgerstats/Categories/utils/category_utils.dart';
import 'package:ledgerstats/Expenses/blocs/expenses_bloc.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ledgerstats/Expenses/utils/expenditure.dart';
import 'package:ledgerstats/database_handler.dart';

class SortedFilteredListView extends StatefulWidget {
  List<Expenditure> data;
  Widget? Function(BuildContext, int) itemBuilder;
  bool isExpanded;
  SortedFilteredListView(
      {required this.data,
      required this.itemBuilder,
      required this.isExpanded});

  @override
  SortedFilteredListViewState createState() => SortedFilteredListViewState();
}

class SortedFilteredListViewState<T> extends State<SortedFilteredListView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SortedFilteredListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: Stack(
        children: [
          ListView.builder(
            itemCount: widget.data.length,
            itemBuilder: widget.itemBuilder,
          ),
          ScaleTransition(
            alignment: Alignment.topLeft,
            scale: _animation,
            child: /*FilterPanel(ExpenseFilterBloc(categoriesInFilter: []),
                checkedCategories: [])*/
                null,
          )
        ],
      ))
    ]);
  }
}

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
                        child: DateTimeField(
                      textAlign: TextAlign.right,
                      initialValue: widget.fromDate,
                      format: DateFormat.yMd(
                          Localizations.localeOf(context).languageCode),
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate:
                                currentValue == DatabaseHandler.defaultDate
                                    ? DateTime.now()
                                    : currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                      onChanged: (DateTime? currentValue) {
                        widget.fromDate = currentValue;
                        BlocProvider.of<ExpenseFilterBloc>(context)
                            .add(ChangeFromDate(date: currentValue));
                      },
                    )),
                  ],
                ),
                Row(
                  children: [
                    Text('to'), //TODO localization
                    Expanded(
                        child: DateTimeField(
                      textAlign: TextAlign.right,
                      initialValue: widget.toDate,
                      format: DateFormat.yMd(
                          Localizations.localeOf(context).languageCode),
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate:
                                currentValue == DatabaseHandler.defaultDate
                                    ? DateTime.now()
                                    : currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                      onChanged: (DateTime? currentValue) {
                        widget.toDate = currentValue;
                        BlocProvider.of<ExpenseFilterBloc>(context)
                            .add(ChangeToDate(date: currentValue));
                      },
                    )),
                  ],
                )
              ])
            ]))));
  }
}
