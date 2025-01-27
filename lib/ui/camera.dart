import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  final CameraDescription camera;
  final Function(String) onPictureTaken;

  const CameraScreen({
    super.key,
    required this.camera,
    required this.onPictureTaken,
  });

  Future<CameraController> _initializeCameraController() async {
    final controller = CameraController(camera, ResolutionPreset.medium);
    await controller.initialize();
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a Picture')),
      body: FutureBuilder<CameraController>(
        future: _initializeCameraController(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final controller = snapshot.data!;

            return Stack(
              children: [
                // Display the camera preview
                CameraPreview(controller),
                // Overlay a capture button
                Positioned(
                  bottom: 50,
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: FloatingActionButton(
                    onPressed: () async {
                      try {
                        // Take the picture
                        final image = await controller.takePicture();

                        // Trigger the callback with the picture's path
                        onPictureTaken(image.path);
                        Navigator.pop(context);
                      } catch (e) {
                        print('Error taking picture: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to capture image: $e'),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                      'Error initializing camera please check the settings and try again'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            ));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
