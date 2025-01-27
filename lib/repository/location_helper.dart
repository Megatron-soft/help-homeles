import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:shelter/models/geolocator_response.dart';
import 'package:http/http.dart' as http;

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
///
class LocationHelper {
  static Future<GeolocatorResponse> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    Location location = Location();

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return GeolocatorResponse(
            lat: 0.0,
            long: 0.0,
            isSuccess: false,
            message: "Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return GeolocatorResponse(
        lat: 0.0,
        long: 0.0,
        isSuccess: false,
        message:
            "Location permissions are permanently denied, we cannot request permissions",
      );
    }
    Position position = await Geolocator.getCurrentPosition();
    return GeolocatorResponse(
      lat: position.latitude,
      isSuccess: true,
      long: position.longitude,
      message: "success",
    );
  }

  static Future<String?> getCityName(double latitude, double longitude) async {
    const apiKey =
        '6744a23973d80796660893pqdaaca2c'; // Replace with your API key
    final url = Uri.parse(
      'https://geocode.maps.co/reverse?lat=$latitude&lon=$longitude&api_key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final city = data['address']['city'];
      if (city.isNotEmpty) {
        return city;
      }
      return null;
    } else {
      return null;
    }
  }
}
