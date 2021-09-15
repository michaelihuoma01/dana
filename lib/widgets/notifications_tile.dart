import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';

class NotificationsTile extends StatelessWidget {
  String? title;

  NotificationsTile({this.title});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset('assets/images/me.jpeg'),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title!,
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('17 seconds ago', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          Container(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/me.jpeg'),
            ),
          ),
        ],
      ),
      SizedBox(height: 20),
      BrandDivider(),
      SizedBox(height: 20),
    ]);
  }
}
