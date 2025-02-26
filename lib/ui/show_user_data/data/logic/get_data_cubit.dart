import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:shelter/helper/helper.dart';
import 'package:shelter/ui/show_user_data/data/model/show_data_response.dart';

part 'get_data_state.dart';

class GetDataCubit extends Cubit<GetDataState> {
  GetDataCubit() : super(GetDataInitial());

  final Dio _dio = Dio();

  Future<void> fetchHomelessData(int id) async {
    emit(HomelessLoading());
    try {
      print('Fetching data for homeless ID: $id...');
      print('Starting request to fetch workshops...');
      print(
        'https://shelter.el-doc.com/api/v1/homelesses/$id}',  // Ensure correct URL
      );
      Options options = Options(
        headers: {
          'Content-Type': '',
          'Accept': 'application/json',
          "X-Localization":CacheHelper.getData(key: "lang")=="ar"?"en":"ar"
        },
      );
      final response = await _dio.get('https://shelter.el-doc.com/api/v1/homelesses/$id',options: options);

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
