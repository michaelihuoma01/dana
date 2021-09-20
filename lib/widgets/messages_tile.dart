import 'package:cached_network_image/cached_network_image.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  bool? unread, online;
  String? url, name, message, time;
  Widget? recentMessage;
  Function? onTap;

  MessageTile(
      {this.online,
      this.recentMessage,
      this.unread,
      this.url,
      this.onTap,
      this.name,
      this.message,
      this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
                height: 70,
                width: 70,
                child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(width: 2)),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 28.0,
                        backgroundImage: (url!.isEmpty
                            ? AssetImage(placeHolderImageRef)
                            : CachedNetworkImageProvider(url!)) as ImageProvider<Object>?,
                      ),
                    ),
                  ),
                  if (online == true)
                    Positioned.fill(
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: darkColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(250))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: InkWell(
                                          onTap: 
                                            onTap as void Function()?
                                          ,
                                          child: Icon(Icons.circle,
                                              color: Colors.greenAccent,
                                              size: 15)),
                                    ))))),
                ])),
            SizedBox(width: 15),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name!,
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  // Text(
                  //     'Hey Itadri! Do you want to come to the cinema tonight? 😊',
                  //     maxLines: 3,
                  //     style: TextStyle(color: Colors.grey)),
                  recentMessage!
                ],
              ),
            ),
            SizedBox(width: 10),
            Column(
              children: [
                Text('7:35 AM', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 5),
                if (unread == true)
                  Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          color: lightColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text('2',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins-Bold')),
                      )),
              ],
            )
          ],
        ),
        SizedBox(height: 20),
        BrandDivider(),
        SizedBox(height: 20),
      ],
    );
  }
}
