import 'package:dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'dart:io';

enum ImageType { ASSET_IMAGE, FILE_IMAGE, NONE, NETWORK_IMAGE }

class ImagePortrait extends StatelessWidget {
  final double height;
  final String imagePath;
  final ImageType imageType;

  ImagePortrait(
      {@required this.imageType, this.imagePath, this.height = 250.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.height * 0.65,
      height: MediaQuery.of(context).size.height / 3,
      decoration: BoxDecoration(
          color: Colors.white70,
          border: Border.all(width: 2, color: lightColor),
          borderRadius: BorderRadius.all(Radius.circular(250))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(220),
        child: getImage(),
      ),
    );
  }

  Widget getImage() {
    if (imageType == ImageType.NONE || imagePath == null) return null;
    if (imageType == ImageType.FILE_IMAGE) {
      return Image.file(File(imagePath), fit: BoxFit.fill);
    } else if (imageType == ImageType.ASSET_IMAGE) {
      return Image.asset(imagePath, fit: BoxFit.fitHeight);
    } else if (imageType == ImageType.NETWORK_IMAGE) {
      return Image.network(imagePath, fit: BoxFit.fitHeight);
    } else
      return null;
  }
}
