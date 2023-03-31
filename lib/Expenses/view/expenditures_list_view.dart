import 'package:budgetizer/Expenses/view/add_expenditure_view.dart';
import 'package:flutter/material.dart';
import 'package:budgetizer/Expenses/view/expenditure_view.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:budgetizer/Expenses/utils/expenditure.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:budgetizer/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/expenses_bloc.dart';
import '../../sorted_filtered_listview.dart';
import '../../app_colors.dart';
import '../../navigation_drawer.dart';

class _ExpendituresState extends State<Expenditures>
    with SingleTickerProviderStateMixin {
  late Future<List<Expenditure>> _dataFuture = DatabaseHandler().fetchData();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.expendFilters ? 1.0 : 0.0,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
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
                      setState(() {
                        widget.expendFilters = !widget.expendFilters;
                        widget.expendFilters
                            ? _controller.reverse()
                            : _controller.forward();
                      });
                    },
                    icon: Icon(Icons.filter_list))
              ],
              title: Text(AppLocalizations.of(context)!.welcomeMessage),
            ),
            key: UniqueKey(),
            body: Column(children: [
              Expanded(
                  child: Stack(children: [
                BlocBuilder<ExpenseFilterBloc, ExpenseFilterState>(
                    builder: (context, state) {
                  List<Expenditure> filteredList =
                      List.from(DatabaseHandler.expendituresList.where(
                    (Expenditure element) {
                      //on date
                      bool fromDateOk = true;
                      if (state.fromDate != null) {
                        //fromDate is before or same moment as element.date
                        fromDateOk =
                            state.fromDate!.compareTo(element.date) <= 0;
                      }
                      bool toDateOk = true;
                      if (state.toDate != null) {
                        //fromDate is after or same moment as element.date
                        toDateOk = state.toDate!.compareTo(element.date) >= 0;
                      }
                      //on category
                      bool categoryFilter = true;
                      if (state.categoriesInFilter.isNotEmpty) {
                        categoryFilter =
                            state.categoriesInFilter.contains(element.category);
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Text(row.category.emoji),
                          subtitle: Text(
                              '${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(row.date)} ${row.value.toString()}€'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ExpenditureView(expenditure: row)),
                            ).then((_) => refreshView());
                          },
                        );
                      });
                }),
                ScaleTransition(
                  alignment: Alignment.topLeft,
                  scale: _animation,
                  child: FilterPanel(widget.expenseFilterBloc,
                      checkedCategories: widget.categoriesFiltered),
                )
              ]))
            ])));
  }

  Future<void> refreshView() => Future(() {
        _dataFuture = DatabaseHandler().fetchData();
        setState(() {});
      });
}

class Expenditures extends StatefulWidget {
  bool expendFilters = false;
  List<bool> categoriesFiltered =
      List.filled(DatabaseHandler.categoriesList.length, false);
  ExpenseFilterBloc expenseFilterBloc =
      ExpenseFilterBloc(categoriesInFilter: []);
  Expenditures({super.key});
  @override
  State<Expenditures> createState() => _ExpendituresState();
}
