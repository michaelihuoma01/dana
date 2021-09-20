import 'package:Dana/utils/constants.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  String? message;
  bool? isSender;

  ChatBubble({this.message, this.isSender});
  @override
  Widget build(BuildContext context) {
    return isSender!
        ? Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300, minWidth: 50),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(message!, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 5),
                        Text('09:25 am',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                )),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300, minWidth: 50),
            child: Container(
              decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 10, right: 10, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(message!,
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 5),
                    Text('09:25 am',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ));
  }
}
