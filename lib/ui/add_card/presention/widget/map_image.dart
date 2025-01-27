import 'package:flutter/material.dart';

class MapImage extends StatelessWidget {
  const MapImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          "lib/res/sss.jpeg",
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),

      ],
    );
  }
}
