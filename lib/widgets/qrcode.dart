import 'package:Dana/screens/auth/login.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDialog extends StatefulWidget {
  String? userID;

  QrDialog({this.userID});
  @override
  _QrDialogState createState() => _QrDialogState();
}

class _QrDialogState extends State<QrDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              // child: Image.asset('assets/images/qr-code.png'),
              child: QrImage(
                data: widget.userID!,
                version: QrVersions.auto,
                size: 300,
                gapless: false,
                backgroundColor: Colors.white,
                embeddedImage: AssetImage('assets/images/icon.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(50, 50),
                ),
              ),
            )));
  }
}
