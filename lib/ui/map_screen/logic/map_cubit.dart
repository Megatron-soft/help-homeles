import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shelter/ui/map_screen/data/models/get_map_workshops_response.dart';


part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapInitial());

  static MapCubit get(context) => BlocProvider.of(context);
  CameraPosition? cameraPosition;
  final Dio _dio = Dio();
  void changeLocation(
    LatLng lat,
  ) {
    this.mapLocation = lat;
    emit(ChangeLocationMapState(latLng: lat));
  }

  LatLng mapLocation = const LatLng(0, 0);

  bool locationButtonFlag = false;

  Completer<GoogleMapController> controller = Completer();

  Future<void> animateCamera() async {
    final GoogleMapController controller = await this.controller.future;
    CameraPosition cameraPosition;
    cameraPosition = CameraPosition(
      target: mapLocation,
      zoom: zoomLevel,
      bearing: mapBearing,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Location location = Location();

  bool buscando = false;
  var zoomLevel = 12.0;
  var mapBearing = 0.0;

  getMyLocation() async {
    location.getLocation().then((value) {
      debugPrint('get location');
      changeLocation(
        LatLng(value.latitude!, value.longitude!),
      );

      debugPrint(
        "${value.latitude} and ${value.longitude}",
      );
      // CacheHelper.saveData(key: "latitude", value: value.latitude!).then((v) {
      //   CacheHelper.saveData(key: "longitude", value: value.longitude!);
      // });
      // firebaseRepo.saveUserLocation(
      //     lat: value.latitude ?? 0, lng: value.longitude ?? 0, speed: 0);
      animateCamera();

      return LatLng(value.latitude!, value.longitude!);
    });
  }
  Future<void> fetchWorkshops({
    required double latitude,
    required double longitude,
  }) async {
    emit(MapLoading());  // Emit loading state
    try {
      print('Starting request to fetch workshops...');

      final response = await _dio.get(
        'https://test.ysk-comics.com/api/v1/filter/homelesses',  // Ensure correct URL
        queryParameters: {
          'latitude': latitude,  // Use function parameters correctly
          'longitude': longitude,
        },
      );

      print('Response received: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('Parsing response data...');
        final result = GetMapWorkshopsResponse.fromJson(response.data);
        print('Parsed data successfully: ${result.data} workshops found');

        emit(MapLoaded(result));  // Emit success state with data
      } else {
        print('Failed to load workshops. Status code: ${response.statusCode}');
        emit(MapError('Failed to load workshops'));
      }
    } catch (e) {
      print('Error occurred: ${e.toString()}');
      emit(MapError('Error: ${e.toString()}'));
    }
  }


// filter/workshops
  // getMapWorkshops({required Map<String, dynamic> queryParams}) async {
  //   emit(GetMapWorkshopsLoadingState());
  //   try {
  //     ApiResponse? response = await ApiManager.sendRequest(
  //       link: 'filter/workshops',
  //       queryParams: queryParams,
  //       method: Method.GET,
  //     );
  //
  //     // Add debug statement for verification
  //     debugPrint('Response status: ${response?.data!['status']}');
  //     debugPrint('Response message: ${response?.data!['message']}');
  //     // debugPrint('Response data: ${response?.data}');
  //
  //     if (response != null && response.statusCode == 200) {
  //       emit(GetMapWorkshopsSuccessState(
  //           data: GetMapWorkshopsResponse.fromJson(response.data!)));
  //     } else {
  //       emit(GetMapWorkshopsErrorState(message: response?.message ?? ''));
  //     }
  //   } catch (e) {
  //     emit(GetMapWorkshopsErrorState(
  //         message:
  //             e is ApiException ? e.message : 'An unexpected error occurred'));
  //   }
  // }
}
