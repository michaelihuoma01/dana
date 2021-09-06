import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:dana/calls/call.dart';
import 'package:dana/calls/call_methods.dart';
import 'package:dana/calls/callscreens/call_screen.dart';
import 'package:dana/calls/callscreens/pickup/cached_image.dart';
import 'package:dana/calls/constants/strings.dart';
import 'package:dana/calls/log.dart';
import 'package:dana/models/user_model.dart';
import 'package:dana/utils/constants.dart';
import 'package:flutter/material.dart';

class PickupScreen extends StatefulWidget {
  final Call call;

  PickupScreen({
    @required this.call,
  });

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();
  // final LogRepository logRepository = LogRepository(isHive: true);
  // final LogRepository logRepository = LogRepository(isHive: false);

  bool isCallMissed = true;
  AudioPlayer audioPlayer = AudioPlayer();

  addToLocalStorage({@required String callStatus}) {
    Log log = Log(
      callerName: widget.call.callerName,
      callerPic: widget.call.callerPic,
      receiverName: widget.call.receiverName,
      receiverPic: widget.call.receiverPic,
      timestamp: DateTime.now().toString(),
      callStatus: callStatus,
    );

    // LogRepository.addLogs(log);
  }

  @override
  void dispose() {
    if (isCallMissed) {
      addToLocalStorage(callStatus: CALL_STATUS_MISSED);
    }
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audioPlayer.play(
        'https://nf1f8200-a.akamaihd.net/downloads/ringtones/files/mp3/classic-5916.mp3',
        isLocal: false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          decoration: new BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    widget.call.callerPic,
                  ))),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              height: double.infinity,
              color: Colors.white.withOpacity(0.0),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.call.callerName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      fontFamily: 'Poppins-Regular',
                      color: Colors.white),
                ),
                Text(
                  "Incoming...",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Poppins-Regular'),
                ),
                SizedBox(height: 50),
                CachedImage(
                  widget.call.callerPic,
                  isRound: true,
                  radius: 150,
                ),
                SizedBox(height: 75),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      child: Column(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Icon(Icons.call_end,
                                  color: Colors.white, size: 35)),
                          SizedBox(height: 5),
                          Text('Decline',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12))
                        ],
                      ),
                      onTap: () async {
                        audioPlayer.stop();
                        isCallMissed = false;
                        addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                        await callMethods.endCall(call: widget.call);
                      },
                    ),
                    GestureDetector(
                        child: Column(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Icon(Icons.call,
                                    color: Colors.white, size: 35)),
                            SizedBox(height: 5),
                            Text('Accept',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12))
                          ],
                        ),
                        onTap: () async {
                          isCallMissed = false;
                          addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                          print(widget.call.isAudio);
                        audioPlayer.stop();

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CallScreen(
                                currentUserId: widget.call.receiverId,
                                  call: widget.call,
                                  isAudio: widget.call.isAudio),
                            ),
                          );
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
