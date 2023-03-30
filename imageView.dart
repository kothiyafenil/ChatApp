import 'package:flutter/material.dart';

class ImageView extends StatefulWidget {
  final String Image;
  const ImageView({super.key, required this.Image});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Image.network(
          widget.Image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
