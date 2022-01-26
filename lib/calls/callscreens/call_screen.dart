import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/calls/call.dart';
import 'package:Dana/calls/call_methods.dart';
import 'package:Dana/calls/callscreens/pickup/cached_image.dart';
import 'package:Dana/calls/configs/agora_configs.dart';
import 'package:Dana/calls/constants/strings.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/home.dart';
import 'package:Dana/screens/pages/direct_messages/nested_screens/chat_screen.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;

class CallScreen extends StatefulWidget {
  final Call call;
  final String? currentUserId;
  final bool? isAudio;

  CallScreen({required this.call, this.isAudio, this.currentUserId});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();

  // UserProvider userProvider;
  late StreamSubscription callStreamSubscription;
  // final GlobalKey<TimerViewState> _timerKey = GlobalKey();

  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool onSpeaker = false;
  bool start = false;
  late RtcEngine _engine;
  int? _remoteUid;
  Timer? _timer;
  int _counter = 0 * 60;
  double height = 180;
  double width = 120;

  @override
  void initState() {
    super.initState();
    addPostFrameCallback();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    // Permission.camera.request();

    if (await Permission.camera.isGranted) {
      print('""""""""""""""""""""""False""""""""""""""""""""""');
    } else {
      Permission.camera.request();
      Permission.microphone.request();
      print('""""""""""""""""""""""True""""""""""""""""""""""');
    }

    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    await _engine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await _engine.joinChannel(null, widget.call.channelId!, null, 0);
  }

  addPostFrameCallback() {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      // userProvider = Provider.of<UserProvider>(context, listen: false);

      callStreamSubscription = callMethods
          .callStream(uid: widget.currentUserId)
          .listen((DocumentSnapshot ds) {
        // defining the logic
        switch (ds.data()) {
          case null:
            // snapshot is null which means that call is hanged and documents are deleted
            Navigator.pop(context);
            break;

          default:
            break;
        }
      });
    });
  }

  /// Create agora sdk instance and initialize

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);

    if (widget.isAudio == false) {
      await _engine.enableVideo();
    }
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, userJoined: (int uid, int elapsed) {
      setState(() {
        final info = 'onUserJoined: $uid';
        setState(() {
          start = true;
          startTimer();
        });
        _infoStrings.add(info);
        _users.add(uid);
        _remoteUid = uid;
      });
    }, userInfoUpdated: (var userInfo, i) {
      setState(() {
        final info = 'onUpdatedUserInfo: ${userInfo.toString()}';
        _infoStrings.add(info);
      });
    }, rejoinChannelSuccess: (String string, int a, int b) {
      setState(() {
        final info = 'onRejoinChannelSuccess: $string';
        _infoStrings.add(info);
      });
    }, userOffline: (var a, b) {
      setState(() {
        final info = 'onUserOffline: a: ${a.toString()}, b: ${b.toString()}';
        _infoStrings.add(info);
        cancelTimer();
      });
    }, localUserRegistered: (var s, i) {
      setState(() {
        final info = 'onRegisteredLocalUser: string: s, i: ${i.toString()}';
        _infoStrings.add(info);
      });
    }, leaveChannel: (var i) {
      setState(() {
        _infoStrings.add('onLeaveChannel ====> $i');

        _users.clear();
      });
    }, connectionLost: () {
      setState(() {
        final info = 'onConnectionLost';
        _users.clear();

        _infoStrings.add(info);
      });
    }, firstRemoteVideoFrame: (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    if (start == true) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _counter++;
        });
        print('====================$_counter');
      });
    }
  }

  String getFormatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    var twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    var twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds ";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _getResendVerificationButton() =>
      Text('${getFormatDuration(Duration(seconds: _counter))}',
          style: TextStyle(fontSize: 18, color: Colors.white));

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<Widget> list = [
      rtc_local_view.SurfaceView(),
      rtc_remote_view.SurfaceView(
        uid: _remoteUid!,
      ),
    ];

    // _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  // Widget _viewRows() {
  // Center(
  //   child: rtc_remote_view.SurfaceView(uid: _remoteUid!),
  // );
  // final views = _getRenderViews();
  // switch (views.length) {
  //   case 1:
  //     return Container(
  //         child: Column(
  //       children: <Widget>[_videoView(views[0])],
  //     ));
  //   case 2:
  //     return Container(
  //         child: Column(
  //       children: <Widget>[
  //         _expandedVideoRow([views[0]]),
  //         _expandedVideoRow([views[1]])
  //       ],
  //     ));
  //   case 3:
  //     return Container(
  //         child: Column(
  //       children: <Widget>[
  //         _expandedVideoRow(views.sublist(0, 2)),
  //         _expandedVideoRow(views.sublist(2, 3))
  //       ],
  //     ));
  //   case 4:
  //     return Container(
  //         child: Column(
  //       children: <Widget>[
  //         _expandedVideoRow(views.sublist(0, 2)),
  //         _expandedVideoRow(views.sublist(2, 4))
  //       ],
  //     ));
  //   default:
  // }
  // return Container();
  // }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _enableSpeaker() {
    if (onSpeaker == false) {
      setState(() {
        onSpeaker = true;
      });
      _engine.setEnableSpeakerphone(true);
    } else {
      setState(() {
        onSpeaker = false;
      });
    }
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
              onTap: _onToggleMute,
              child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: muted ? Colors.white : Colors.white.withOpacity(0.3),
                  ),
                  padding: const EdgeInsets.all(14),
                  // width: 30.0,
                  child: Icon(muted ? Icons.mic : Icons.mic_off,
                      color:
                          muted ? Colors.black.withOpacity(0.7) : Colors.white,
                      size: 20.0))),
          SizedBox(width: 20),
          GestureDetector(
              onTap: () async {
                await _engine.leaveChannel().then((value) {
                  var callDuration =
                      getFormatDuration(Duration(seconds: _counter));

                  print('++++++++++++++++++++++++$callDuration');

                  callMethods.endCall(
                      call: widget.call,
                      duration: callDuration,
                      isMissed: (_remoteUid == null) ? true : false,
                      timestamp: Timestamp.now());

                  // Navigator.pop(context);
                });
              },
              child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  padding: const EdgeInsets.all(15),
                  // width: 30.0,
                  child:
                      Icon(Icons.call_end, color: Colors.white, size: 20.0))),
          SizedBox(width: 20),
          (widget.isAudio == false)
              ? GestureDetector(
                  onTap: _onSwitchCamera,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: Icon(
                      Icons.flip_camera_ios_rounded,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    padding: const EdgeInsets.all(15.0),
                  ),
                )
              : GestureDetector(
                  onTap: _enableSpeaker,
                  child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: onSpeaker
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                      padding: const EdgeInsets.all(15),
                      // width: 30.0,
                      child: Icon(FontAwesomeIcons.volumeUp,
                          color: onSpeaker
                              ? Colors.black.withOpacity(0.8)
                              : Colors.white,
                          size: 17.0))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    callStreamSubscription.cancel();
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: (widget.isAudio == false)
            ? Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  children: [
                    (_remoteUid != null)
                        ? Center(
                            child:
                                rtc_remote_view.SurfaceView(uid: _remoteUid!))
                        : Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 80),
                              child: Text('Connecting...',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                    Positioned(
                      top: 30,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          if (height == 180 && width == 120) {
                            setState(() {
                              height = 570;
                              width = 350;
                            });
                          } else {
                            setState(() {
                              height = 180;
                              width = 120;
                            });
                          }
                        },
                        child: Container(
                            height: height,
                            width: width,
                            child: Center(child: rtc_local_view.SurfaceView())),
                      ),
                    ),
                    if (start == true)
                      Positioned(
                          top: 10,
                          left: 10,
                          right: 0,
                          child: Row(
                            children: [
                              Text(
                                  ' ${(widget.call.receiverId != widget.currentUserId) ? widget.call.callerName! : widget.call.receiverName!} | ',
                                  style: TextStyle(
                                      fontFamily: 'Poppins-Regular',
                                      fontSize: 16,
                                      color: Colors.white)),
                              _getResendVerificationButton()
                            ],
                          )),
                  ],
                ),
                bottomNavigationBar: _toolbar(),
              )
            : Container(
                height: double.infinity,
                decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        begin: Alignment.topCenter,
                        colors: [Color(0xff6fcf97), Color(0xff52bac6)])),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: CachedImage(
                              (widget.call.receiverId == widget.currentUserId)
                                  ? widget.call.callerPic
                                  : widget.call.receiverPic,
                              isRound: true,
                              radius: 100,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                              (widget.call.receiverId == widget.currentUserId)
                                  ? widget.call.callerName!
                                  : widget.call.receiverName!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  fontFamily: 'Poppins-Regular',
                                  color: Colors.white)),
                          if (_remoteUid == null)
                            Text('Connecting...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                        ],
                      ),
                      if (start == true)
                        Positioned(
                            top: 10,
                            left: 15,
                            right: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    (widget.call.receiverId ==
                                            widget.currentUserId)
                                        ? widget.call.callerName!
                                        : widget.call.receiverName!,
                                    style: TextStyle(
                                        fontFamily: 'Poppins-Regular',
                                        fontSize: 16,
                                        color: Colors.white)),
                                _getResendVerificationButton()
                              ],
                            )),
                      // _toolbar(),
                    ],
                  ),
                  bottomNavigationBar: _toolbar(),
                )));
  }
}
