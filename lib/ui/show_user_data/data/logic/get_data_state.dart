part of 'get_data_cubit.dart';

@immutable
sealed class GetDataState {}

final class GetDataInitial extends GetDataState {}
class HomelessLoading extends GetDataState {}

class HomelessLoaded extends GetDataState {
  final GetDataResponse data;
  HomelessLoaded(this.data);
}

class HomelessError extends GetDataState {
  final String errorMessage;
  HomelessError(this.errorMessage);
}