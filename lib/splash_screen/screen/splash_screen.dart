import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shelter/ui/map_screen/logic/map_cubit.dart';
import 'package:shelter/ui/map_screen/presentation/screen/map_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }
    }

    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return position;
  }

  @override
  void initState() {
    super.initState();

    // Define the duration for which the splash screen should be displayed

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<
                MapCubit>(), // Use value if the cubit is already created
            child: MapScreen(
              isVisible: true,
            ),
          ),
        ),
      ).then((_){
        _getCurrentLocation();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.grey[200],
      // Customize the appearance of your splash screen
      body: Center(
        child: Image.asset("lib/res/logo.png"),
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
