import 'dart:math';

import 'package:Dana/calls/call.dart';
import 'package:Dana/calls/call_methods.dart';
import 'package:Dana/calls/callscreens/call_screen.dart';
import 'package:Dana/calls/constants/strings.dart';
import 'package:Dana/calls/log.dart';
import 'package:Dana/calls/log_repository.dart';
import 'package:Dana/models/user_model.dart';
import 'package:flutter/material.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial(
      {required AppUser from,
      required AppUser to,
      context,
      bool? isAudio}) async {
    Call call = Call(
      callerId: from.id,
      callerName: from.name,
      callerPic: from.profileImageUrl,
      receiverId: to.id,
      secondReceiverId: null,
      thirdReceiverId: null,
      receiverName: to.name,
      secondReceiverName: null,
      thirdReceiverName: null,
      isAudio: isAudio,
      receiverPic: to.profileImageUrl,
      secondReceiverPic: null,
      thirdReceiverPic: null,
      channelId: Random().nextInt(1000).toString(),
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.profileImageUrl,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profileImageUrl,
      timestamp: DateTime.now().toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      // enter log
      // LogRepository.addLogs(log);
      // print(call.hasDialled);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CallScreen(call: call, currentUserId: from.id, isAudio: isAudio),
        ),
      );
    }
  }

  static multipleDial(
      {required AppUser from,
      required AppUser to,
      required AppUser secondTo,
      required AppUser thirdTo,
      context,
      channelName,
      bool? isAudio}) async {
    Call call = Call(
      callerId: from.id,
      callerName: from.name,
      callerPic: from.profileImageUrl,
      receiverId: to.id,
      secondReceiverId: secondTo.id,
      thirdReceiverId: thirdTo.id,
      receiverName: to.name,
      secondReceiverName: secondTo.name,
      thirdReceiverName: thirdTo.name,
      isAudio: isAudio,
      receiverPic: to.profileImageUrl,
      secondReceiverPic: secondTo.profileImageUrl,
      thirdReceiverPic: thirdTo.profileImageUrl,
      channelId: channelName,
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.profileImageUrl,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profileImageUrl,
      timestamp: DateTime.now().toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      // enter log
      // LogRepository.addLogs(log);
      // print(call.hasDialled);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CallScreen(call: call, currentUserId: from.id, isAudio: isAudio),
        ),
      );
    }
  }
}
