import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FriendRequestTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              height: 50,
              width: 50,
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 2)),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset('assets/images/me.jpeg'),
                    ),
                  ),
                ),
              ])),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yuji Itadri',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                Text('PIN: 273EF774',
                    maxLines: 3, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(width: 30),
          Row(
            children: [
              Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(Icons.done, color: darkColor)),
              SizedBox(width: 20),
              Icon(Icons.cancel, color: Colors.red, size: 35),
            ],
          )
        ],
      ),
      SizedBox(height: 30),
    ]);
  }
}
