import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OutgoingVideoCall extends StatefulWidget {
  @override
  _OutgoingVideoCallState createState() => _OutgoingVideoCallState();
}

class _OutgoingVideoCallState extends State<OutgoingVideoCall> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          // decoration: new BoxDecoration(
          //     gradient: new LinearGradient(
          //         begin: Alignment.topCenter,
          //         colors: [Color(0xff6fcf97), Color(0xff52bac6)]))),
          child: Image.asset(
            'assets/images/me.jpeg',
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
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Faridah'),
                      Text('5:56', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  automaticallyImplyLeading: true,
                  centerTitle: false)),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [])),
        ),
        Positioned(
            top: 100,
            right: 10,
            child: Container(
                color: Colors.grey.withOpacity(0.8),
                height: 150,
                width: 110,
                child:
                    Image.asset('assets/images/buju.jpeg', fit: BoxFit.cover))),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50))),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 30, left: 20, right: 20),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Icon(Icons.mic_off,
                                color: Colors.white, size: 30),
                          )),
                      SizedBox(width: 15),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Icon(Icons.volume_up,
                                color: Colors.white, size: 30),
                          )),
                      SizedBox(width: 15),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Icon(Icons.flip_camera_ios_rounded,
                                color: Colors.white, size: 30),
                          )),
                      SizedBox(width: 15),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Icon(Icons.videocam_off,
                                color: Colors.white, size: 30),
                          )),
                    ]),
                SizedBox(height: 15),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.red,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child:
                          Icon(Icons.call_end, color: Colors.white, size: 30),
                    )),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}
