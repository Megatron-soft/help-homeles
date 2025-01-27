import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:shelter/ui/show_user_data/data/model/show_data_response.dart';

part 'get_data_state.dart';

class GetDataCubit extends Cubit<GetDataState> {
  GetDataCubit() : super(GetDataInitial());

  final Dio _dio = Dio();

  Future<void> fetchHomelessData(int id) async {
    emit(HomelessLoading());
    try {
      print('Fetching data for homeless ID: $id...');

      final response = await _dio.get('https://test.ysk-comics.com/api/v1/homelesses/$id');

      print('Response received: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('Parsing response data...');
        final result = GetDataResponse.fromJson(response.data);
        print('Data parsed successfully: ${result.data}');
        emit(HomelessLoaded(result));
      } else {
        print('Failed to fetch data, status code: ${response.statusCode}');
        emit(HomelessError('Failed to load data'));
      }
    } catch (e) {
      print('Error occurred: ${e.toString()}');
      emit(HomelessError('Error: ${e.toString()}'));
    }
  }
}
