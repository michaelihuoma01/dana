import 'package:dana/models/models.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/BrandDivider.dart';
import 'package:dana/widgets/appbar_widget.dart';
import 'package:dana/widgets/calls_tile.dart';
import 'package:flutter/material.dart';

class CallsScreen extends StatefulWidget {
  AppUser currentUser;

  CallsScreen({this.currentUser});

  @override
  _CallsScreenState createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        height: double.infinity,
        color: darkColor,
        child: Image.asset(
          'assets/images/background.png',
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              title: Text('Calls',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'Poppins-Regular',
                      fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              centerTitle: false,
              automaticallyImplyLeading: false,
              elevation: 0,
              brightness: Brightness.dark,
            )),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                CallTile(audio: false, missed: true),
                CallTile(audio: true, missed: false),
                CallTile(audio: false, missed: false),
              ],
            ),
          ),
        ),
      )
    ]);
  }
}
