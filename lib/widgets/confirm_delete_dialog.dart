import 'package:Dana/screens/auth/login.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeleteDialog extends StatefulWidget {
  Function? onPressed;
  String? userName;

  DeleteDialog({this.onPressed, this.userName});
  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
            height: 100,
            margin: EdgeInsets.all(50),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(children: [
                      Text('Delete chat with ${widget.userName}?',
                          textAlign: TextAlign.center, style: TextStyle()),
                      // Divider(color: Colors.black),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                              onTap: widget.onPressed as void Function()?,
                              child: Text('Delete',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red))),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle())),
                        ],
                      ),
                    ])))));
  }
}
