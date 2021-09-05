import 'package:flutter/material.dart';

class OutgoingAudioCall extends StatefulWidget {
  @override
  _OutgoingAudioCallState createState() => _OutgoingAudioCallState();
}

class _OutgoingAudioCallState extends State<OutgoingAudioCall> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: new BoxDecoration(
          gradient: new LinearGradient(
              begin: Alignment.topCenter,
              colors: [Color(0xff6fcf97), Color(0xff52bac6)])),
      child: Stack(
        children: [
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
                        Text('Ringing...', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    automaticallyImplyLeading: true,
                    centerTitle: false)),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                  Container(
                      height: 200,
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(150),
                        child: Image.asset('assets/images/me.jpeg'),
                      )),
                ])),
          ),
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
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Icon(Icons.mic_off,
                                    color: Colors.white, size: 35),
                              )),
                          SizedBox(width: 15),

                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Icon(Icons.volume_up,
                                    color: Colors.white, size: 35),
                              )),
                          SizedBox(width: 15),
                          // Container(
                          //     decoration: BoxDecoration(
                          //       borderRadius:
                          //           BorderRadius.circular(50),
                          //       color: Colors.white.withOpacity(0.2),
                          //     ),
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(20),
                          //       child: Icon(
                          //           Icons.flip_camera_ios_rounded,
                          //           color: Colors.white,
                          //           size: 35),
                          //     )),
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.red,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Icon(Icons.close,
                                    color: Colors.white, size: 35),
                              )),
                        ]),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
