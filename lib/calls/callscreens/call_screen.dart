import 'dart:async';

import 'package:Dana/models/models.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/utility.dart';
import 'package:Dana/widgets/button_widget.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:share/share.dart';

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

  StreamSubscription? callStreamSubscription;
  // final GlobalKey<TimerViewState> _timerKey = GlobalKey();

  List<int> _users = [];
  final _infoStrings = <String>[];
  bool muted = false;
  bool onSpeaker = false;
  bool start = false;
  bool isVideoEnabled = true;
  RtcEngine? _engine;
  int? _remoteUid, _uid;
  Timer? _timer;
  int _counter = 0 * 60;
  double height = 180;
  double width = 120;
  Uri? dynamicUrl;
  var link;
  String? state;
  List<AppUser> _userFollowing = [];
  List<String?> _selectedUsers = [];

  List<bool> _userFollowingState = [];
  int _followingCount = 0;
  bool _isLoading = false;
  bool? _selected = false;
  final TextEditingController _messageController = TextEditingController();
  bool isSending = false;

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
    await _engine!.enableWebSdkInteroperability(true);
    await _engine!.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await _engine!.joinChannel(null, widget.call.channelId!, null, 0);
    link = await createVideoLink();
    await _setupFollowing();
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

  Future _setupFollowing() async {
    setState(() {
      _isLoading = true;
    });

    int userFollowingCount =
        await DatabaseService.numFollowing(widget.currentUserId);
    if (!mounted) return;
    setState(() {
      _followingCount = userFollowingCount;
    });

    List<String> userFollowingIds =
        await DatabaseService.getUserFollowingIds(widget.currentUserId);

    List<AppUser> userFollowing = [];
    List<bool> userFollowingState = [];
    for (String userId in userFollowingIds) {
      AppUser user = await DatabaseService.getUserWithId(userId);
      userFollowingState.add(true);
      userFollowing.add(user);
    }
    setState(() {
      _userFollowingState = userFollowingState;
      _userFollowing = userFollowing;
      _followingCount = userFollowing.length;
      if (_followingCount != _followingCount) {
        setState(() => _followingCount = _followingCount);
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  // Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);

    if (widget.isAudio == false) {
      await _engine!.enableVideo();
      isVideoEnabled = true;
    }
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine!.setEventHandler(RtcEngineEventHandler(error: (dynamic code) {
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
    }, remoteVideoStateChanged: (uid, stats, reason, ela) {
      setState(() {
        print('-------$uid');
        _uid = uid;
        print('-------${stats.name}');
        state = stats.name;
        print('-------$reason');
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

  List<Widget> _getRenderViews() {
    final List<Widget> list = [];
    list.add((isVideoEnabled == true)
        ? rtc_local_view.SurfaceView()
        : Container(
            child: Center(
                child: Text('Camera off',
                    style: TextStyle(color: Colors.white)))));
    _users.forEach((int uid) => list.add((state == 'Stopped' && _uid == uid)
        ? Container(
            child: Center(
                child:
                    Text('Camera off', style: TextStyle(color: Colors.white))))
        : rtc_remote_view.SurfaceView(uid: uid)));
    return list;
  }

  _sendMessage(
      {String? text,
      String? imageUrl,
      String? giphyUrl,
      String? audioUrl,
      String? videoUrl,
      String? fileUrl,
      String? fileName,
      AppUser? receiver}) async {
    if ((text != null && text.trim().isNotEmpty) ||
        (fileName != null && fileName.trim().isNotEmpty) ||
        imageUrl != null ||
        audioUrl != null ||
        videoUrl != null ||
        fileUrl != null ||
        giphyUrl != null) {
      setState(() => isSending = true);

      List<String?> userIds = [];
      userIds.add(widget.currentUserId);
      userIds.add(receiver!.id);

      Chat? chat = await ChatService.getChatByUsers(userIds);

      bool isChatExist = chat != null;

      if (!isChatExist) {
        chat = await ChatService.createChat([
          Provider.of<UserData>(context, listen: false).currentUser,
          receiver
        ], userIds, context);

        setState(() {
          isChatExist = true;
        });
      }

      if (imageUrl == null &&
          giphyUrl == null &&
          audioUrl == null &&
          videoUrl == null &&
          fileUrl == null) {
        _messageController.clear();
      }

      Message message = Message(
        senderId: widget.currentUserId,
        text: text,
        imageUrl: imageUrl,
        fileName: fileName,
        giphyUrl: giphyUrl,
        audioUrl: audioUrl,
        videoUrl: videoUrl,
        fileUrl: fileUrl,
        timestamp: Timestamp.now(),
        isLiked: false,
      );

      ChatService.sendChatMessage(chat, message, receiver, context, false);
      chatsRef.doc(chat.id).update({'readStatus.${receiver.id}': false});
      setState(() => isSending = false);
    }
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
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

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

  Future<Uri> createVideoLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://danasocialapp.page.link', //$route',
      link: Uri.parse(
          'https://danasocialapp.page.link/?joinCall=${widget.call.channelId}&video=${widget.isAudio.toString()}'), //$route?code=$code'),
      androidParameters: AndroidParameters(
          packageName: 'com.michaelihuoma.dana', minimumVersion: 1),
      iosParameters: IOSParameters(
          bundleId: 'com.dubaitechnologydesign.dana',
          minimumVersion: '1',
          appStoreId: '1589760284'),
      navigationInfoParameters:
          NavigationInfoParameters(forcedRedirectEnabled: true),
    );

    dynamicUrl =
        (await FirebaseDynamicLinks.instance.buildShortLink(parameters))
            .shortUrl;

    print(dynamicUrl);
    return dynamicUrl!;
  }

  void _addUsers() async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              width: double.infinity,
              decoration: BoxDecoration(color: darkColor),
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 10),
                          child: Text('Add people to call',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: link.toString()));
                                },
                                child: Text(link.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16, color: lightColor))),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: link.toString()));

                                Utility.showMessage(context,
                                    bgColor: Colors.green,
                                    message: 'Link copied',
                                    pulsate: false);
                              },
                              child: Icon(Icons.copy_outlined,
                                  color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () {
                                Share.share(
                                    'Click to join ${widget.call.callerName}\'s group call: \n${dynamicUrl.toString()}');
                              },
                              child: Icon(Icons.ios_share, color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.white),
                        SizedBox(height: 10),
                        Expanded(
                          child: Container(
                            child: ListView.builder(
                              itemCount: _userFollowing.length,
                              itemBuilder: (BuildContext context, int index) {
                                AppUser follower = _userFollowing[index];
                                String? filteritem = _selectedUsers.firstWhere(
                                    (item) => item == follower.id,
                                    orElse: () => null);
                                return ListTile(
                                  leading: Container(
                                    height: 40,
                                    width: 40,
                                    child: CircleAvatar(
                                      radius: 25.0,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: (follower
                                                  .profileImageUrl!.isEmpty
                                              ? AssetImage(placeHolderImageRef)
                                              : CachedNetworkImageProvider(
                                                  follower
                                                      .profileImageUrl!))
                                          as ImageProvider<Object>?,
                                    ),
                                  ),
                                  title: Text(follower.name!,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18)),
                                  subtitle: Text('PIN: ${follower.pin}',
                                      maxLines: 3,
                                      style: TextStyle(color: Colors.grey)),
                                  trailing: GestureDetector(
                                    onTap: () async {
                                      AppUser receiver =
                                          await DatabaseService
                                              .getUserWithId(follower.id);

                                      _sendMessage(
                                          text: link.toString(),
                                          receiver: receiver,
                                          imageUrl: null,
                                          giphyUrl: null,
                                          audioUrl: null,
                                          videoUrl: null,
                                          fileName: null,
                                          fileUrl: null);
                                      Utility.showMessage(context,
                                          message: 'Link sent',
                                          pulsate: false,
                                          bgColor: Colors.green[600]!);
                                    },
                                    child: Icon(Ionicons.send,
                                        color: lightColor, size: 19),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                         
                      ])));
        });
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine!.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine!.switchCamera();
  }

  void _enableSpeaker() {
    if (onSpeaker == false) {
      setState(() {
        onSpeaker = true;
      });
      _engine!.setEnableSpeakerphone(true);
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
              onTap: _addUsers,
              child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  padding: const EdgeInsets.all(12),
                  child:
                      Icon(Icons.link_rounded, color: Colors.white, size: 18))),
          SizedBox(width: 20),
          GestureDetector(
              onTap: _onToggleMute,
              child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: muted ? Colors.white : Colors.white.withOpacity(0.3),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(muted ? Icons.mic_off : Icons.mic_off,
                      color:
                          muted ? Colors.black.withOpacity(0.7) : Colors.white,
                      size: 18))),
          SizedBox(width: 20),
          GestureDetector(
              onTap: () async {
                await _engine!.leaveChannel().then((value) {
                  setState(() {
                    if (_users.length > 1) {
                      var callDuration =
                          getFormatDuration(Duration(seconds: _counter));

                      Navigator.pop(context);
                    } else {
                      var callDuration =
                          getFormatDuration(Duration(seconds: _counter));

                      callMethods.endCall(
                          call: widget.call,
                          duration: callDuration,
                          isMissed: (_remoteUid == null) ? true : false,
                          timestamp: Timestamp.now());
                    }
                  });
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
                      size: 18,
                    ),
                    padding: const EdgeInsets.all(12),
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
                      padding: const EdgeInsets.all(12),
                      // width: 30.0,
                      child: Icon(FontAwesomeIcons.volumeUp,
                          color: onSpeaker
                              ? Colors.black.withOpacity(0.8)
                              : Colors.white,
                          size: 15))),
          SizedBox(width: 20),
          if (widget.isAudio == false)
            GestureDetector(
                onTap: () {
                  if (isVideoEnabled == true) {
                    setState(() {
                      isVideoEnabled = false;
                      _engine!.enableLocalVideo(false);
                    });
                  } else {
                    setState(() {
                      isVideoEnabled = true;
                      _engine!.enableLocalVideo(true);
                    });
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isVideoEnabled
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white,
                    ),
                    padding: const EdgeInsets.all(12),
                    // width: 30.0,
                    child: Icon(Icons.videocam_off_rounded,
                        color: isVideoEnabled
                            ? Colors.white
                            : Colors.black.withOpacity(0.7),
                        size: 18))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine!.leaveChannel();
    _engine!.destroy();
    callStreamSubscription!.cancel();
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
                        ?
                        // Center(
                        //     child:
                        //         rtc_remote_view.SurfaceView(uid: _remoteUid!))
                        _viewRows()
                        : Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 80),
                              child: Text('Connecting...',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                    // Positioned(
                    //   top: 30,
                    //   right: 10,
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       if (height == 180 && width == 120) {
                    //         setState(() {
                    //           height = 570;
                    //           width = 350;
                    //         });
                    //       } else {
                    //         setState(() {
                    //           height = 180;
                    //           width = 120;
                    //         });
                    //       }
                    //     },
                    //     child: Container(
                    //         height: height,
                    //         width: width,
                    //         child: Center(child: rtc_local_view.SurfaceView())),
                    //   ),
                    // ),
                    // if (start == true)
                    //   Positioned(
                    //       top: 10,
                    //       left: 10,
                    //       right: 0,
                    //       child: Row(
                    //         children: [
                    //           Text(
                    //               ' ${(widget.call.receiverId != widget.currentUserId) ? widget.call.callerName! : widget.call.receiverName!} | ',
                    //               style: TextStyle(
                    //                   fontFamily: 'Poppins-Regular',
                    //                   fontSize: 16,
                    //                   color: Colors.white)),
                    //           _getResendVerificationButton()
                    //         ],
                    //       )),
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
