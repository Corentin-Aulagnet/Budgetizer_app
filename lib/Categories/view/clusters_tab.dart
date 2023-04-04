import 'package:ledgerstats/Categories/utils/category_utils.dart';
import 'package:ledgerstats/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ledgerstats/Categories/blocs/categories_bloc.dart';

class ClustersTab extends StatelessWidget {
  final GlobalKey _draggableKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryViewBloc, CategoryViewState>(
        builder: (context, state) {
      return ListView(
        children: List.generate(
            List<CategoryDescriptor>.from(DatabaseHandler.categoriesList
                .where((element) => element.isCluster())).length, (index) {
          CategoryDescriptor cluster =
              DatabaseHandler.clustersCategories[index];
          return DragTarget<CategoryDescriptor>(
            builder: (context, candidateItems, rejectedItems) {
              return LongPressDraggable<CategoryDescriptor>(
                  dragAnchorStrategy: pointerDragAnchorStrategy,
                  feedback: DraggingListItem(
                    dragKey: _draggableKey,
                    category: cluster,
                  ),
                  data: cluster,
                  child: ExpansionTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text('${cluster.emoji} ${cluster.name}'),
                    children: List.generate(
                        List<CategoryDescriptor>.from(DatabaseHandler
                                .nonClustersCategories
                                .where((element) => element.parent == cluster))
                            .length,
                        (index) => LongPressDraggable<CategoryDescriptor>(
                            dragAnchorStrategy: pointerDragAnchorStrategy,
                            data: List<CategoryDescriptor>.from(DatabaseHandler
                                .nonClustersCategories
                                .where((element) =>
                                    element.parent == cluster))[index],
                            feedback: DraggingListItem(
                              dragKey: _draggableKey,
                              category: List<CategoryDescriptor>.from(
                                  DatabaseHandler.nonClustersCategories.where(
                                      (element) =>
                                          element.parent == cluster))[index],
                            ),
                            child: ListTile(
                              leading: Text(List<CategoryDescriptor>.from(
                                      DatabaseHandler.nonClustersCategories
                                          .where((element) =>
                                              element.parent == cluster))[index]
                                  .emoji),
                              title: Text(List<CategoryDescriptor>.from(
                                      DatabaseHandler.nonClustersCategories
                                          .where((element) =>
                                              element.parent == cluster))[index]
                                  .name),
                            ))),
                    onExpansionChanged: (bool expanded) {
                      CategoryViewBloc bloc =
                          BlocProvider.of<CategoryViewBloc>(context);
                      expanded
                          ? bloc.add(CategoryExpanded(index: index))
                          : bloc.add(CategoryRetracted(index: index));
                    },
                  ));
            },
            onAccept: (item) {
              if (item.children.isEmpty) {
                BlocProvider.of<CategoryViewBloc>(context).add(
                    CategoryAncestryModified(
                        currentCategory: item, newParent: cluster));
              }
            },
          );
        }),
      );
    });
  }
}

class DraggingListItem extends StatelessWidget {
  const DraggingListItem(
      {super.key, required this.dragKey, required this.category});

  final GlobalKey dragKey;
  final CategoryDescriptor category;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Row(
      children: [Text(category.emoji), Text(category.name)],
    ));
  }
}
