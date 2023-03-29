import 'package:budgetizer/Categories/blocs/categories_bloc.dart';
import 'package:budgetizer/create_category_view.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:budgetizer/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:budgetizer/Categories/view/clusters_tab.dart';
import 'package:budgetizer/Categories/utils/category_utils.dart';
import 'package:patterns_canvas/patterns_canvas.dart';

import '../../app_colors.dart';
import '../../navigation_drawer.dart';

class CategoriesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => CategoryViewBloc(clustersExpanded: []),
        child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: AddCategoryFAB(),
            drawer: AppNavigationDrawer(),
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.welcomeMessage),
            ),
            body: Column(children: [
              Expanded(flex: 3, child: ClustersTab()),
              Spacer(flex: 2),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(child: ReleaseTarget()),
                    Expanded(child: DeleteTarget())
                  ],
                ),
              )
            ])));
  }
}

class AddCategoryFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateCategoryView()))
            .then((_) => BlocProvider.of<CategoryViewBloc>(context)
                .add(CategoryAdded()));
      },
      backgroundColor: AppColors.secondaryColor,
      child: const Icon(Icons.add),
    );
  }
}

class ReleaseTarget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryViewBloc, CategoryViewState>(
        builder: (context, state) {
      return DragTarget<CategoryDescriptor>(
        builder: (context, candidateItems, rejectedItems) {
          return CustomPaint(
              painter: DropActionRect(
                  bgColor: Colors.blueAccent.shade400, fgColor: Colors.white),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Release",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ));
        },
        onAccept: (item) {
          BlocProvider.of<CategoryViewBloc>(context).add(
              CategoryAncestryModified(currentCategory: item, newParent: null));
        },
      );
    });
  }
}

class DeleteTarget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryViewBloc, CategoryViewState>(
        builder: (context, state) {
      return DragTarget<CategoryDescriptor>(
        builder: (context, candidateItems, rejectedItems) {
          return CustomPaint(
              painter: DropActionRect(
                  bgColor: Colors.red.shade700, fgColor: Colors.red.shade400),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Delete",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ));
        },
        onAccept: (item) {
          showDeleteDialog(context, item, () {
            BlocProvider.of<CategoryViewBloc>(context).add(CategoryDeleted());
          });
        },
      );
    });
  }
}

class DropActionRect extends CustomPainter {
  Color bgColor;
  Color fgColor;
  DropActionRect({required this.bgColor, required this.fgColor});
  @override
  void paint(Canvas canvas, Size size) {
    DiagonalStripesThick(bgColor: bgColor, fgColor: fgColor)
        .paintOnWidget(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
