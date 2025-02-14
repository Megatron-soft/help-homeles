part of 'add_card_cubit.dart';

@immutable
sealed class AddCardState {}

final class AddCardInitial extends AddCardState {}
class CategoriesInitial extends AddCardState {}

class CategoriesLoading extends AddCardState {}

class CategoriesLoaded extends AddCardState {
  final ShowAllCategories categories;

  CategoriesLoaded(this.categories);
}

class CategoriesError extends AddCardState {
  final String message;

  CategoriesError(this.message);
}
class Categories2Loading extends AddCardState {}

class Categories2Loaded extends AddCardState {
  final ShowAllCategories2 categories;

  Categories2Loaded(this.categories);
}

class Categories2Error extends AddCardState {
  final String message;

  Categories2Error(this.message);
}

class AddCardLoading extends AddCardState {}

class AddCardSuccess extends AddCardState {
  final String message;
  AddCardSuccess(this.message);
}

class AddCardError extends AddCardState {
  final String message;
  AddCardError(this.message);
}
