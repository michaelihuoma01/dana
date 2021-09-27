import 'package:Dana/screens/pages/user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScanner extends StatefulWidget {
  String? currentUserID;

  QrCodeScanner(this.currentUserID);

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      setState(() {
        result = scanData;
        print(result?.code);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfile(
                    currentUserId: widget.currentUserID,
                    userId: result?.code))).then((value) => controller.resumeCamera());
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Scan QR Code'),
          automaticallyImplyLeading: true,
          backgroundColor: darkColor,
          iconTheme: IconThemeData(color: Colors.white),
          brightness: Brightness.dark,
          elevation: 5, 
        ),
        body: Stack(
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ],
        ));
  }
}
