import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shelter/helper/helper.dart';
import 'package:shelter/ui/add_card/logic/cubit/add_card_cubit.dart';
import 'package:shelter/ui/map_screen/logic/map_cubit.dart';
import 'package:shelter/ui/map_screen/presentation/screen/map_screen.dart';
import 'package:shelter/ui/search_results/ui/screen/search_results_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }
    }

    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }


  void _showLocationErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return AlertDialog(
          title: const Text("Location Permission Required"),
          content: const Text("Please enable GPS to continue."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await Geolocator.openLocationSettings(); // Open GPS settings

                // Delay and retry location fetching
                Future.delayed(const Duration(seconds: 3), () async {
                  Position? position = await _getCurrentLocation();
                  if (position != null) {
                    _navigateToNextScreen(position.latitude, position.longitude);
                  }
                });
              },
              child: const Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () async {
      CacheHelper.saveData(key: "lang", value: "ar");

      try {
        // Attempt to get location before navigating
        Position? position = await _getCurrentLocation();

        if (position != null) {
          _navigateToNextScreen(position.latitude, position.longitude);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get location. Please enable GPS and try again.')),
          );
        }
      } catch (e) {
        print("Location error: $e");

        // Show a Snackbar asking the user to enable GPS manually
        _showLocationErrorDialog(context);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Error fetching location: $e'),
        //     action: SnackBarAction(
        //       label: 'Open Settings',
        //       onPressed: () {
        //         Geolocator.openLocationSettings(); // Open GPS settings
        //       },
        //     ),
        //   ),
        // );
      }
    });
  }


  void _navigateToNextScreen(double lat, double lng) {
    CacheHelper.saveData(key: "latitude", value: lat.toString());
    CacheHelper.saveData(key: "longitude", value: lng.toString());
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
  providers: [
    BlocProvider.value(
          value: context.read<MapCubit>(), // Keep existing MapCubit instance
),
    BlocProvider(
      create: (context) => AddCardCubit(),
    ),
  ],
  child: SearchResultsScreen(),
),
      ),
          (route) => false, // Remove all previous routes from the stack
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      // Customize the appearance of your splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Let Us Help Each Other ",
                style: TextStyle(fontSize: 22.sp, fontStyle: FontStyle.italic,fontWeight: FontWeight.bold)
            ),
            SizedBox(
              height: 20.h,
            ),
            Image.asset("lib/res/logo.png"),
            SizedBox(
              height: 20.h,
            ),
            Text(
              "اعمل خير وارميه ف البحر",
                style: TextStyle(fontSize: 22.sp, fontStyle: FontStyle.italic,fontWeight: FontWeight.bold)
            ),
          ],
        ),
        // child: Text(getLang(context, "CAR SERVICES").toString(),
        //     style: TextStyle(
        //         fontSize: 40.sp,
        //         fontWeight: FontWeight.w400,
        //         fontFamily: 'Darumadrop One',
        //         color: const Color(0xFF6BB56B))),
      ),
    );
  }
}
