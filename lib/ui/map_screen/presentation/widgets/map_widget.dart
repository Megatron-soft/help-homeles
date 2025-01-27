import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart'; // for rootBundle
import 'dart:typed_data'; // for Uint8List
import 'dart:ui' as ui; // for ui.Image, PictureRecorder
import 'package:flutter/services.dart'; // for rootBundle
import 'dart:typed_data'; // for Uint8List
import 'dart:ui' as ui; // for ui.Image, PictureRecorder
import 'dart:ui' as ui;

import 'package:shelter/ui/map_screen/presentation/screen/map_screen.dart';

class MapWidget extends StatelessWidget {
  final Function() onCameraIdle;
  final Function(CameraPosition) onCameraMove;
  final Function() onCameraMoveStarted;
  final Function(GoogleMapController) onMapCreated;
  final LatLng target;
  final List<MarkerModel> cars;
  double? zoom;
  final Function(int) onMarkerTap; // Added callback for marker tap

  MapWidget({
    super.key,
    this.zoom,
    required this.onCameraIdle,
    required this.onCameraMove,
    required this.onCameraMoveStarted,
    required this.onMapCreated,
    required this.target,
    required this.cars,
    required this.onMarkerTap, // Initialize callback
    required this.polylines, // Initialize callback
  });

  final Set<Polyline> polylines;

  // Future<BitmapDescriptor> _getCarIcon(String carType) async {
  //   String assetPath;
  //   if (carType == "type1") {
  //     assetPath = 'assets/image/type1.png'; // Make sure the image file exists
  //   } else if (carType == "type2") {
  //     assetPath = 'assets/image/type2.png'; // Change accordingly
  //   } else {
  //     assetPath = 'assets/image/type3.png'; // Change accordingly
  //   }
  //
  //   // Load image from asset
  //   final ByteData data = await rootBundle.load(assetPath);
  //   final Uint8List bytes = data.buffer.asUint8List();
  //
  //   // Create a BitmapDescriptor from the image bytes
  //   return BitmapDescriptor.fromBytes(bytes);
  // }

  Future<BitmapDescriptor> _getCarIcon(String imageUrl) async {
    try {
      // Fetch the image data from the URL
      final ByteData imageData =
          await NetworkAssetBundle(Uri.parse(imageUrl)).load("");
      final Uint8List bytes = imageData.buffer.asUint8List();

      // Decode image
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      // Convert the image to bytes for BitmapDescriptor
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final size =
          Size(frame.image.width.toDouble(), frame.image.height.toDouble());
      canvas.drawImage(frame.image, Offset.zero, Paint());

      final picture = pictureRecorder.endRecording();
      final img =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      // Return a default marker if the image fails to load
      return BitmapDescriptor.defaultMarker;
    }
  }

  // Future<Set<Marker>> _createCarMarkers() async {
  //   List<Marker> markerList = []; // Create a list to store markers
  //   for (var entry in cars.asMap().entries) {
  //     final markerId = 'car_${entry.key}';
  //     final carType = entry.value.type; // Get the car type
  //
  //     // Load the BitmapDescriptor asynchronously
  //     final icon = await _getCarIcon(carType);
  //
  //     // Create the marker and add it to the list
  //     Marker marker = Marker(
  //       markerId: MarkerId(markerId),
  //       position: entry.value.location,
  //       icon: icon,
  //       onTap: () => onMarkerTap(entry.key),
  //     );
  //     markerList.add(marker); // Add the marker to the list
  //   }
  //   return markerList.toSet(); // Convert the list to a set and return it
  // }

  Future<Set<Marker>> _createCarMarkers() async {
    List<Marker> markerList = [];
    for (var entry in cars.asMap().entries) {
      final markerId = 'car_${entry.key}';
      final imageUrl = entry.value.workShopImage; // Use the URL directly

      final icon = await _getCarIcon(imageUrl); // Fetch the icon dynamically

      Marker marker = Marker(
        markerId: MarkerId(markerId),
        position: entry.value.location,
        icon: icon,
        onTap: () => onMarkerTap(entry.key),
      );
      markerList.add(marker);
    }
    return markerList.toSet();
  }

  Future<void> _applyCustomMapStyle(GoogleMapController controller) async {
    String style = await rootBundle.loadString('assets/map_style.json');
    controller.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<Marker>>(
      future: _createCarMarkers(), // Call the method to create markers
      builder: (context, snapshot) {
        final markers = snapshot.data ?? {}; // Get the markers
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: target,
            zoom: zoom ?? 12.0,
          ),
          markers: markers,
          // Use the markers obtained from FutureBuilder
          onMapCreated: (GoogleMapController controller) {
            onMapCreated(controller); // Call the provided callback
            _applyCustomMapStyle(controller); // Apply custom style
          },
          onCameraMoveStarted: onCameraMoveStarted,
          onCameraMove: onCameraMove,
          onCameraIdle: onCameraIdle,
          trafficEnabled: true,
          indoorViewEnabled: true,
          compassEnabled: false,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          mapToolbarEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          polylines: polylines, // Include the polylines in the map
        );
      },
    );
  }
}
