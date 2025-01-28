import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shelter/helper/helper.dart';
import 'package:shelter/ui/add_card/presention/screen/add_screen.dart';
import 'package:shelter/ui/bloc/homeless_bloc.dart';
import 'package:shelter/ui/map_screen/data/models/get_map_workshops_response.dart';
import 'package:shelter/ui/show_user_data/presentation/screen/show_user_data.dart';
import 'package:shelter/ui/widgets/drower.dart';
import 'package:shelter/ui/widgets/image_prev.dart';

import '../../data/models/get_map_workshops_response.dart';
import '../../logic/map_cubit.dart';
import '../widgets/map_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  MapScreen({super.key, required this.isVisible});

  bool isVisible;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class MarkerModel {
  final int id;

  final String address;
  final String image;

  final String workShopImage;
  final List<Categories> categories;
  final double distance;
  final LatLng location;

  MarkerModel({
    required this.id,
    required this.address,
    required this.image,
    required this.workShopImage,
    required this.categories,
    required this.distance,
    required this.location,
  });
}

List<MarkerModel> markers = [
  // MarkerModel(
  //   title: 'title1',
  //   type: 'type1',
  //   address: 'address1',
  //   workShopImage: "assets/image/test_image.png",
  //   workShopProfileImage: "assets/image/test_image.png",
  //   distance: '3.7',
  //   rating: 4,
  //   location: const LatLng(29.910106292526795, 31.2937043979764),
  // ),
  // MarkerModel(
  //   title: 'title2',
  //   type: 'type2',
  //   address: 'address2',
  //   distance: '2.5',
  //   workShopImage: "assets/image/test_image.png",
  //   workShopProfileImage: "assets/image/test_image.png",
  //   rating: 3,
  //   location: const LatLng(26.8207, 30.8026),
  // ),
  // MarkerModel(
  //   title: 'title3',
  //   type: 'type3',
  //   address: 'address3',
  //   workShopImage: "assets/image/test_image.png",
  //   workShopProfileImage: "assets/image/test_image.png",
  //   distance: '4.9',
  //   rating: 1,
  //   location: const LatLng(26.8210, 30.8030),
  // ),
];

class _MapScreenState extends State<MapScreen> {
  late MapCubit cubit;
  int? selectedCarIndex; // Index of the selected car marker

  // void onCameraMove(CameraPosition position) {
  //   cubit.zoomLevel = position.zoom;
  //   cubit.mapBearing = position.bearing;
  //   cubit.mapLocation = position.target;
  // }

  void onMapCreated(GoogleMapController controller) {
    cubit.controller.complete(controller);
  }

  void onCameraMove(CameraPosition position) {
    cubit.zoomLevel = position.zoom;
    cubit.mapBearing = position.bearing;
    cubit.mapLocation = position.target;

    // Update the camera position in the cubit for reference
    cubit.cameraPosition = position;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert degrees to radians
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in kilometers
  }

  LatLng? _lastLocation;

  void onCameraIdle() {
    final currentLocation = cubit.cameraPosition?.target;

    if (currentLocation != null) {
      if (_lastLocation == null ||
          _calculateDistance(
                _lastLocation!.latitude,
                _lastLocation!.longitude,
                currentLocation.latitude,
                currentLocation.longitude,
              ) >
              20) {
        // Update the last known location
        _lastLocation = currentLocation;
        MapCubit.get(context).fetchWorkshops(
          latitude: double.parse(currentLocation.latitude.toString()),
          // "latitude": "29.9792",
          longitude: double.parse(currentLocation.longitude.toString()),
          // "longitude": "31.2357",
        );
        // Trigger the API request
        // MapCubit.get(context).getMapWorkshops(queryParams: {
        //   "type": "map",
        //   "latitude": currentLocation.latitude.toString(),
        //   "longitude": currentLocation.longitude.toString(),
        // });
      }
    }
  }

  // void onMarkerTap(int index) {
  //   setState(() {
  //     selectedCarIndex = index; // Store index of selected marker
  //   });
  // }

  void onMarkerTap(int index) {
    setState(() {
      selectedCarIndex = index; // Store index of selected marker
    });

    // Get directions from current location to selected marker
    // final destination =
    //     markers[index].location; // Get the location of the tapped marker
    // DirectionsService.getDirections(cubit.mapLocation, destination)
    //     .then((route) {
    //   // Here, you can display the route on the map using polylines
    //   _displayRoute(route);
    // });
  }

  /// for directions
  Set<Polyline> _polylines = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    cubit = MapCubit.get(context);
    MapCubit.get(context).getMyLocation();

    super.initState();
  }

  /// for directions
  // void _displayRoute(List<LatLng> route) {
  //   // Here you would add a polyline to the map using the route coordinates
  //   final polyline = Polyline(
  //     polylineId: PolylineId('route'),
  //     color: Colors.blue,
  //     points: route,
  //     width: 5,
  //   );
  //
  //   setState(() {
  //     _polylines.add(polyline); // Add to the list of polylines to be displayed
  //   });
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    // cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Text(
            CacheHelper.getData(key: "lang")=="ar"?"home":"الصفحه الرئيسيه",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: InkWell(
                onTap: () {
                  _scaffoldKey.currentState
                      ?.openDrawer(); // Open Drawer using key
                },
                child: SvgPicture.asset(
                  'lib/res/drawer.svg',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: widget.isVisible
            ? BlocConsumer<MapCubit, MapState>(
                listener: (context, state) {
                  if (state is ChangeLocationMapState) {
                    MapCubit.get(context).fetchWorkshops(
                      latitude: double.parse(state.latLng.latitude.toString()),
                      // "latitude": "29.9792",
                      longitude: double.parse(state.latLng.longitude.toString()),
                      // "longitude": "31.2357",
                    );
                  }
                  if (state is MapLoaded) {
                    setState(() {
                      markers = state.response.data!
                          .map(
                            (e) => MarkerModel(
                              id: e.id!,
                              image: e.image!,
                              workShopImage: "lib/res/marker.png",
                              categories: e.categories!,
                              address: e.address!,
                              distance: double.parse(e.distance.toString()),
                              location: LatLng(double.parse(e.latitude!),
                                  double.parse(e.longitude!)),
                            ),
                          )
                          .toList();
                    });
                  }
                },
                builder: (context, state) {
                  return Stack(
                    children: [
                      MapWidget(
                        onCameraIdle: onCameraIdle,
                        polylines: _polylines,
                        onCameraMove: onCameraMove,
                        zoom: 12.0,
                        onCameraMoveStarted: () {},
                        onMapCreated: onMapCreated,
                        target: cubit.mapLocation,
                        cars: markers,
                        onMarkerTap: onMarkerTap, // Pass marker tap handler
                      ),
                      if (selectedCarIndex != null)
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCarIndex = null; // Clear selected marker
                              });
                            },
                          ),
                        ),
                      if (selectedCarIndex !=
                          null) // Show details container if marker is selected
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: _buildDetailsContainer(),
                        ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCardScreen(),
                              ),
                            );
                          },
                          icon: Container(
                            width: 50,  // Set width and height equally to create a circle
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,  // Make the container circular
                            ),
                            child: Center(
                              child: Icon(Icons.add, color: Colors.red, size: 30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            : const SizedBox.shrink(),
        drawer: AppDrawer(),
        // floatingActionButton: FloatingActionButton(
        //   shape: const CircleBorder(),
        //   backgroundColor: Colors.black,
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => AddCardScreen(),
        //       ),
        //     );
        //   },
        //   child: const Icon(Icons.add, color: Colors.white),
        // ),
      ),
    );
  }

  Widget _buildDetailsContainer() {
    final location = markers[selectedCarIndex!];
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowUserData(
              id: location.id,
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // WorkshopPreviewImage(imagePath: "",),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    CacheHelper.getData(key: "lang")=="ar"? "address: ":"العنوان: ",
                    style: TextStyle(color: Colors.black, fontSize: 20.sp),
                  ),  Text(
                    location.address,
                    style: TextStyle(color: Colors.black, fontSize: 20.sp),
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(
                  height: 5.h,
                ),
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        location.categories[index].name,
                        style: TextStyle(color: Colors.black, fontSize: 20.sp),
                      ),
                    ],
                  );
                },
                itemCount: location.categories.length,
              ),
              Text(
                CacheHelper.getData(key: "lang")=="ar"? "distance: ${location.distance.toInt()} K":"المسافه: ${location.distance.toInt()} كيلو",
                style: TextStyle(color: Colors.black, fontSize: 20.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
