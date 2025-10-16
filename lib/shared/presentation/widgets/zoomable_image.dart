import 'package:flutter/material.dart';

class ZoomableImage extends StatelessWidget {
  final String imagePath;
  const ZoomableImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: Image.asset(imagePath, fit: BoxFit.contain),
    );
  }
}

