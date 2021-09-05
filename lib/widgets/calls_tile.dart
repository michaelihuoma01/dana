import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';

class CallTile extends StatelessWidget {
  bool missed, audio;

  CallTile({this.missed, this.audio});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
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
          SizedBox(width: 15),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yuji Itadri',
                    style: TextStyle(
                        color: missed ? Colors.red : Colors.white,
                        fontSize: 20)),
                Row(
                  children: [
                    Icon(audio ? Icons.call : Icons.video_call,
                        color: Colors.grey),
                    SizedBox(width: 10),
                    Text('Incoming', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Spacer(),
          Text('7:35 AM', style: TextStyle(color: Colors.grey)),
        ],
      ),
      SizedBox(height: 10),
      BrandDivider(),
      SizedBox(height: 10),
    ]);
  }
}
