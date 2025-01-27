import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shelter/models/geolocator_response.dart';
import 'package:shelter/models/homeless_data.dart';
import 'package:shelter/models/response.dart';
import 'package:shelter/repository/location_helper.dart';
import 'package:shelter/ui/helpers/helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomelessCubit extends Cubit<Response> {
  HomelessCubit()
      : super(Response(
            isLoading: false,
            isFailed: false,
            loaded: false,
            need: "",
            distance: -1,
            homelessData: [],
            filteredData: []));

  Future<void> addPerson(CardData card, File? image, String path) async {
    String imageUrl = await uploadImage(path);
    String? cityName = await LocationHelper.getCityName(card.lat,card.long);

    if (imageUrl.isEmpty) {
      Helper.showToast("Please check connection and try again");
      return;
    }

    String description = card.needs.map((need) => need.need).join(', ');

    final response = await Supabase.instance.client.from('homeless').insert({
      'lat': card.lat,
      'long': card.long,
      'city': cityName,
      'description': description,
      'image_url': imageUrl
    });

    print(response);
    CardData newCard = CardData(
        needs: card.needs, lat: card.lat, long: card.long, imageUrl: imageUrl, city: cityName);
    final updatedState = List<CardData>.from(state.homelessData)..add(newCard);
    emit(Response(
        isLoading: false,
        isFailed: false,
        loaded: true,
        need: state.need,
        distance: state.distance,
        homelessData: updatedState,
        filteredData: updatedState));
  }

  Future<void> updatePerson(CardData card) async {

    String description = card.needs.map((need) => need.need).join(', ');
    String? cityName = await LocationHelper.getCityName(card.lat,card.long);


    final response = await Supabase.instance.client.from('homeless').update({
      'lat': card.lat,
      'long': card.long,
      'description': description,
      'image_url': card.imageUrl
    }).eq('image_url', card.imageUrl ?? "");

    print(response);
    CardData newCard = CardData(
        needs: card.needs, lat: card.lat, long: card.long, imageUrl: card.imageUrl,city: cityName);
    final updatedState = List<CardData>.from(state.homelessData)..add(newCard);
    emit(Response(
        isLoading: false,
        isFailed: false,
        loaded: true,
        need: state.need,
        distance: state.distance,
        homelessData: updatedState,
        filteredData: updatedState));
  }

  Future<String> uploadImage(String path) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/${dotenv.env['CLOUD_NAME']}/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'ynqosycz'
      ..files.add(await http.MultipartFile.fromPath('file', path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jasonMap = jsonDecode(responseString);
      return jasonMap['url'];
    } else {
      return "";
    }
  }

  Future<void> getHomelessData() async {
    emit(Response(
        isLoading: true,
        isFailed: false,
        loaded: false,
        need: state.need,
        distance: state.distance,
        homelessData: [],
        filteredData: []));
    try {
      // Query the 'homeless' table from Supabase
      final response = await Supabase.instance.client.from('homeless').select();

      // Parse the data and update the state
      final List<CardData> data = [];

      for (var homeless in response) {
        CardData card = CardData.fromJson(homeless);
        data.add(card);
      }

      emit(Response(
          isLoading: false,
          isFailed: false,
          loaded: true,
          need: state.need,
          distance: state.distance,
          homelessData: data,
          filteredData: data));
    } catch (e) {
      Helper.showToast("Please try again later");
      emit(Response(
          isLoading: false,
          isFailed: true,
          loaded: true,
          need: state.need,
          distance: state.distance,
          homelessData: [],
          filteredData: []));
    }
  }

  Future<void> sortHomeless() async {
    // Start with loading state
    emit(Response(
        isLoading: true,
        isFailed: false,
        loaded: false,
        need: state.need,
        distance: state.distance,
        homelessData: state.homelessData,
        filteredData: state.homelessData));

    double lat = -1.0;
    double long = -1.0;

    // Fetch the location
    GeolocatorResponse geoResponse = await LocationHelper.determinePosition();
    Helper.showToast("Please wait while location is fetched");

    if (geoResponse.isSuccess) {
      lat = geoResponse.lat;
      long = geoResponse.long;
      Helper.showToast("Location fetched successfully");
    } else {
      Helper.showToast("Please check the location and try again");

      // Early return if location fetch fails
      emit(Response(
          homelessData: state.homelessData,
          filteredData: state.homelessData,
          need: state.need,
          distance: state.distance,
          isFailed: true,
          isLoading: false,
          loaded: false));
      return; // Stop further execution
    }

    // Sort homelessData based on distance from current location
    final homelessData = List<CardData>.from(state.homelessData);
    homelessData.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(lat, long, a.lat, a.long);
      double distanceB = Geolocator.distanceBetween(lat, long, b.lat, b.long);
      return distanceA.compareTo(distanceB); // Sort from closest to furthest
    });

    // Emit sorted homeless data and mark loading as finished
    emit(Response(
        homelessData: homelessData,
        filteredData: homelessData,
        need: state.need,
        distance: state.distance,
        isFailed: false,
        isLoading: false,
        loaded: true));
  }

  void setDistance(int distance) {
    Response response = state;
    response.distance = distance;
    emit(response);
    _filterData(true);
  }

  void setNeed(String need) {
    Response response = state;
    response.need = need;
    emit(response);
    _filterData(false);
  }

  Future<void> _filterData(bool loadLocation) async {
    emit(Response(
        isLoading: true,
        isFailed: false,
        loaded: false,
        need: state.need,
        distance: state.distance,
        homelessData: state.homelessData,
        filteredData: state.homelessData));

    double lat = -1.0;
    double long = -1.0;
    if(loadLocation){
    // Fetch the location
    GeolocatorResponse geoResponse = await LocationHelper.determinePosition();
    Helper.showToast("Please wait while location is fetched");

    if (geoResponse.isSuccess) {
      lat = geoResponse.lat;
      long = geoResponse.long;
      Helper.showToast("Location fetched successfully");
    } else {
      Helper.showToast("Please check the location and try again");

      // Early return if location fetch fails
      emit(Response(
          homelessData: state.homelessData,
          filteredData: state.homelessData,
          need: state.need,
          distance: state.distance,
          isFailed: true,
          isLoading: false,
          loaded: false));
      return; // Stop further execution
    }
    }

    List<CardData> filtered = [];

    if (state.need == "" && state.distance == -1) {
      filtered = state.homelessData;
    } else if (state.need == "") {
      filtered = _filterBasedOnDistance(lat, long);
    } else if (state.distance == -1) {
      filtered = _filterOnNeed(state.homelessData);
    } else {
      filtered = _filterBasedOnDistance(lat, long);
      filtered = _filterOnNeed(filtered);
    }

    emit(Response(
      distance: state.distance,
      need: state.need,
      isLoading: false,
      loaded: true,
      isFailed: false,
      homelessData: state.homelessData,
      filteredData: filtered,
    ));
  }

  List<CardData> _filterBasedOnDistance(double lat, double long) {
    // Filter and sort the list by distance
    List<CardData> filtered =
        List<CardData>.from(state.homelessData).where((card) {
      double distance =
          Geolocator.distanceBetween(lat, long, card.lat, card.long);
      return distance < state.distance;
    }).toList();

    filtered.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(lat, long, a.lat, a.long);
      double distanceB = Geolocator.distanceBetween(lat, long, b.lat, b.long);
      return distanceA.compareTo(distanceB); // Sort from closest to furthest
    });

    return filtered;
  }

  List<CardData> _filterOnNeed(List<CardData> filtered) {
    List<CardData> needFiltered = [];
    for (var person in filtered) {
      for(var need in person.needs){
        if(need.need == state.need){
          needFiltered.add(person);
          break;
        }
      }
      
    }
    return needFiltered;
  }
}
