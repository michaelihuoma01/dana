import 'package:cached_network_image/cached_network_image.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchTile extends StatelessWidget {
  bool? unread, online;
  String? url, name, pin;

  SearchTile({this.online, this.unread, this.name, this.url, this.pin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 40,
              width: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: url!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                      height: 200, child: SpinKitCircle(color: Colors.white)),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name!,
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  Text('PIN: $pin',
                      maxLines: 3, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
