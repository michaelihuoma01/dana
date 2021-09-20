import 'package:cached_network_image/cached_network_image.dart';
import 'package:Dana/utils/constants.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String? imageUrl;
  FullScreenImage(this.imageUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: darkColor,
          iconTheme: IconThemeData(color: Colors.white),
          brightness: Brightness.dark,
          elevation: 5,
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.file_download))
          ],
        ),
        body: Stack(
          children: [
            Container(
                color: darkColor,
                child: Center(
                    child: Hero(
                  tag: imageUrl!,
                  child: CachedNetworkImage(
                      imageUrl: imageUrl!, fit: BoxFit.contain),
                ))),
          ],
        ));
  }
}
