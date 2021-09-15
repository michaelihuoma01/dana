import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';

class StoryAppbar extends StatelessWidget {
  bool? unread, online;

  StoryAppbar({this.online, this.unread});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Container(
            height: 50,
            width: 50,
            child: Stack(children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(width: 2, color: lightColor)),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset('assets/images/me.jpeg'),
                  ),
                ),
              ),
            ])),
        SizedBox(width: 15),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yuji Itadri',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
        ),
        SizedBox(width: 10),
        Spacer(),
        Row(
          children: [
            Icon(Icons.more_horiz, color: Colors.white),
            SizedBox(width: 10),
            Icon(Icons.close, color: Colors.white),
          ],
        )
      ])
    ]);
  }
}
