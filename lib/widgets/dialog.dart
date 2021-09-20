import 'package:Dana/screens/auth/login.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ImageDialog extends StatefulWidget {
  Function? onVideo, onPhotos, onDocument;

  ImageDialog({this.onDocument, this.onVideo, this.onPhotos});
  @override
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          height: 150,
            margin: EdgeInsets.all(30),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(children: [
                      Text(
                          'A link to reset your password has been sent to your email, reset your password and login again',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18)),
                      Divider(color: Colors.black),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                                (Route<dynamic> route) => false);
                          },
                          child: Text('Go to login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: lightColor))),
                    ])))));
  }
}
