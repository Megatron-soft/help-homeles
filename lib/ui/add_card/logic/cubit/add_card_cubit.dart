import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:shelter/helper/helper.dart';
import 'package:shelter/ui/add_card/data/model/show_all_categories.dart';

part 'add_card_state.dart';

class AddCardCubit extends Cubit<AddCardState> {
  AddCardCubit() : super(AddCardInitial());
  static AddCardCubit get(context) => BlocProvider.of(context);
  File? selectedLogo;

  final Dio _dio = Dio();

  Future<void> fetchCategories(String url) async {
    emit(CategoriesLoading());
    try {
      Options options = Options(
        headers: {
          'Content-Type': '',
          'Accept': 'application/json',
          "X-Localization":CacheHelper.getData(key: "lang")=="ar"?"en":"ar"
        },
      );
      final response = await _dio.get('$url/categories',options:options );
      if (response.statusCode == 200) {
        final data = ShowAllCategories.fromJson(response.data);
        emit(CategoriesLoaded(data));
      } else {
        emit(CategoriesError("Failed to fetch categories"));
      }
    } catch (e) {
      emit(CategoriesError("Error: ${e.toString()}"));
    }
  }


  Future<void> submitForm({
    required File imagePath,
    required double latitude,
    required double longitude,
    required String country,
    required String note,
    required List<int> categories,
  }) async {
    emit(AddCardLoading());

    try {
      FormData formData = FormData.fromMap({
        'image_file': await MultipartFile.fromFile(
          imagePath.path,
          filename: imagePath.path.split('/').last,
        ),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'country': country.toString(),
        'note': note.trim(),
        'categories[]': categories.isNotEmpty ? categories : null,
      });

      Options options = Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          "X-Localization":CacheHelper.getData(key: "lang")=="ar"?"en":"ar"
        },
      );

      final response = await Dio().post(
        'https://shelter.megatron-soft.com/api/v1/homelesses',
        data: formData,
        options: options,
      );

      if (response.statusCode == 200) {
        print(response.data['message']);
        emit(AddCardSuccess(response.data['message']));
      } else {
        print("Failed to submit form: ${response.statusCode}");
        emit(AddCardError("Failed to submit form"));
      }
    } catch (e) {
      if (e is DioException) {
        print('Error response: ${e.response?.data}');
      }
      emit(AddCardError("Error: ${e.toString()}"));
    }
  }



}
