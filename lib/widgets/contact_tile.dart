import 'package:cached_network_image/cached_network_image.dart';
import 'package:dana/models/user_model.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  AppUser? appUser;
  ContactTile({this.appUser});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 40,
              width: 40,
              child: CircleAvatar(
                radius: 25.0,
                backgroundColor: Colors.grey,
                backgroundImage: (appUser!.profileImageUrl!.isEmpty
                    ? AssetImage(placeHolderImageRef)
                    : CachedNetworkImageProvider(appUser!.profileImageUrl!)) as ImageProvider<Object>?,
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appUser!.name!,
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text(
                      (appUser!.bio == '')
                          ? 'PIN: ${appUser!.pin}'
                          : '${appUser!.bio}',
                      maxLines: 3,
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            // Expanded(child: Container()),
            // Row(
            //   children: [
            //     Icon(Icons.chat, color: Colors.white),
            //     SizedBox(width: 10),
            //     Icon(Icons.call, color: Colors.white),
            //     SizedBox(width: 10),
            //     Icon(Icons.video_call, color: Colors.white),
            //   ],
            // )
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
