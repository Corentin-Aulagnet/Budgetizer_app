import 'package:budgetizer/Categories/utils/category_utils.dart';
import 'package:budgetizer/database_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//Events
abstract class CategoryEvent {
  CategoryEvent();
}

class CategoryAdded extends CategoryEvent {
  CategoryAdded() : super();
}

class CategoryModified extends CategoryEvent {
  CategoryModified() : super();
}

class CategoryDeleted extends CategoryEvent {
  CategoryDeleted() : super();
}

class CategoryAncestryModified extends CategoryEvent {
  CategoryDescriptor? newParent;
  CategoryDescriptor currentCategory;
  CategoryAncestryModified(
      {required this.currentCategory, required this.newParent})
      : super();
}

class CategoryExpanded extends CategoryEvent {
  int index;
  CategoryExpanded({required this.index}) : super();
}

class CategoryRetracted extends CategoryEvent {
  int index;
  CategoryRetracted({required this.index}) : super();
}

//States
abstract class CategoryViewState {
  CategoryViewState();
}

class CategoryViewChanged extends CategoryViewState {
  List<int> clustersExpanded;
  CategoryViewChanged({
    required this.clustersExpanded,
  }) : super();
}

//Bloc
class CategoryViewBloc extends Bloc<CategoryEvent, CategoryViewState> {
  List<int> clustersExpanded; //useless?
  CategoryViewBloc({required this.clustersExpanded})
      : super(CategoryViewChanged(
          clustersExpanded: clustersExpanded,
        )) {
    on<CategoryExpanded>(onCategoryExpanded);
    on<CategoryRetracted>(onCategoryRetracted);
    on<CategoryDeleted>(onCategoryDeleted);
    on<CategoryAdded>(onCategoryAdded);
    on<CategoryAncestryModified>(onCategoryAncestryModified);
  }

  void onCategoryExpanded(
      CategoryExpanded event, Emitter<CategoryViewState> emit) {
    clustersExpanded.add(event.index);
    emit(CategoryViewChanged(clustersExpanded: clustersExpanded));
  }

  void onCategoryRetracted(
      CategoryRetracted event, Emitter<CategoryViewState> emit) {
    clustersExpanded.remove(event.index);
    emit(CategoryViewChanged(clustersExpanded: clustersExpanded));
  }

  void onCategoryDeleted(
      CategoryDeleted event, Emitter<CategoryViewState> emit) {
    emit(CategoryViewChanged(clustersExpanded: clustersExpanded));
  }

  void onCategoryAdded(CategoryAdded event, Emitter<CategoryViewState> emit) {
    emit(CategoryViewChanged(clustersExpanded: clustersExpanded));
  }

  void onCategoryAncestryModified(
      CategoryAncestryModified event, Emitter<CategoryViewState> emit) async {
    //remove the currentCategory from the children of the old parent
    event.currentCategory.parent?.children.remove(event.currentCategory);
    CategoryDescriptor? oldParent = event.currentCategory.parent;
    //set the new parent
    event.currentCategory.parent = event.newParent;
    //set the new children
    if (event.newParent != null) {
      event.currentCategory.parent!.addChild(event.currentCategory);
    }
    await DatabaseHandler()
        .updateCategories([event.currentCategory, oldParent, event.newParent]);
    emit(CategoryViewChanged(clustersExpanded: clustersExpanded));
  }
}
