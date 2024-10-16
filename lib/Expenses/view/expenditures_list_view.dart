import 'package:flutter/foundation.dart';
import 'package:ledgerstats/Categories/utils/category_utils.dart';
import 'package:ledgerstats/Expenses/view/add_expenditure_view.dart';
import 'package:flutter/material.dart';
import 'package:ledgerstats/Expenses/view/expenditure_view.dart';
import 'package:ledgerstats/database_handler.dart';
import 'package:ledgerstats/Expenses/utils/expenditure.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ledgerstats/sorted_filtered_listview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ledgerstats/Expenses/blocs/expenses_bloc.dart';

import 'package:ledgerstats/app_colors.dart';
import 'package:ledgerstats/navigation_drawer.dart';

class _ExpendituresState extends State<Expenditures>
    with SingleTickerProviderStateMixin {
  final Future<Data> _dataFuture = DatabaseHandler().getData();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 0.0,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  /*void _togglePopOut() {
    setState(() {
      widget.isPopOutVisible = !widget.isPopOutVisible;
      if (widget.isPopOutVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }*/
  void _togglePopOut() {
    widget.isPopOutVisible = !widget.isPopOutVisible;
    if (widget.isPopOutVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpenseFilterBloc>(
        create: (context) => widget.expenseFilterBloc,
        child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                //We need a bloc for the expenditureList view to refresh only this widget after a expenditure has been added
                // Add your onPressed code here!
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddExpenditureView()))
                    .then((_) => refreshView());
              },
              backgroundColor: AppColors.secondaryColor,
              child: const Icon(Icons.add),
            ),
            drawer: AppNavigationDrawer(),
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () {
                      _togglePopOut();
                    },
                    icon: const Icon(Icons.filter_list))
              ],
              title: Text(AppLocalizations.of(context)!.welcomeMessage),
            ),
            key: UniqueKey(),
            body: FutureBuilder<Data>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                      onTap: () {
                        if (widget.isPopOutVisible) {
                          _togglePopOut();
                        }
                      },
                      child: Column(children: [
                        Expanded(
                            child: Stack(children: [
                          BlocBuilder<ExpenseFilterBloc, ExpenseFilterState>(
                              builder: (context, state) {
                            List<Expenditure> filteredList =
                                List.from(snapshot.data!.expenses.where(
                              (Expenditure element) {
                                //on date
                                bool fromDateOk = true;
                                if (state.fromDate != null) {
                                  //fromDate is before or same moment as element.date
                                  fromDateOk =
                                      state.fromDate!.compareTo(element.date) <=
                                          0;
                                }
                                bool toDateOk = true;
                                if (state.toDate != null) {
                                  //fromDate is after or same moment as element.date
                                  toDateOk =
                                      state.toDate!.compareTo(element.date) >=
                                          0;
                                }
                                //on category
                                bool categoryFilter = true;
                                if (state.categoriesInFilter.isNotEmpty) {
                                  categoryFilter = state.categoriesInFilter
                                      .contains(element.category);
                                }
                                return categoryFilter && fromDateOk && toDateOk;
                              },
                            ));
                            return ListView.builder(
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  Expenditure row = filteredList[index];
                                  return ListTile(
                                    title: Text(
                                        '${row.title} | ${row.category.getName(context)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    trailing: Text(row.category.emoji),
                                    subtitle: Text(
                                        '${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(row.date)} ${row.value.toString()}€'),
                                    onTap: () {
                                      if (!widget.isPopOutVisible) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ExpenditureView(
                                                      id: row.dataBaseId)),
                                        ).then((_) => refreshView());
                                      } else {
                                        _togglePopOut();
                                      }
                                    },
                                  );
                                });
                          }),
                          Align(
                            alignment: Alignment.topRight,
                            child: FilterPanel(
                              widget.expenseFilterBloc,
                              categories: List.from(snapshot.data!.categories.where((CategoryDescriptor cat)=> cat.isChild())),
                              checkedCategories: widget.categoriesFiltered,
                              animation: _animation,
                              controller: _controller,
                            ),
                          )
                        ]))
                      ]));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )));
  }

  Future<void> refreshView() => Future(() {
        //DatabaseHandler().fetchAll();
        setState(() {});
      });
}

class FilterAnimateCubit extends Cubit<bool> {
  FilterAnimateCubit() : super(false);

  void animate() => emit(!state);
}

class Expenditures extends StatefulWidget {
  bool isPopOutVisible = false;
  List<bool> categoriesFiltered =
      List.filled(DatabaseHandler.categoriesList.length, false);
  ExpenseFilterBloc expenseFilterBloc =
      ExpenseFilterBloc(categoriesInFilter: []);
  Expenditures({super.key});
  @override
  State<Expenditures> createState() => _ExpendituresState();
}
