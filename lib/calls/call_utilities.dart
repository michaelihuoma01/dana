import 'dart:math';

import 'package:dana/calls/call.dart';
import 'package:dana/calls/call_methods.dart';
import 'package:dana/calls/callscreens/call_screen.dart';
import 'package:dana/calls/constants/strings.dart';
import 'package:dana/calls/log.dart';
import 'package:dana/calls/log_repository.dart';
import 'package:dana/models/user_model.dart';
import 'package:flutter/material.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({AppUser from, AppUser to, context, bool isAudio}) async {
    Call call = Call(
      callerId: from.id,
      callerName: from.name,
      callerPic: from.profileImageUrl,
      receiverId: to.id,
      receiverName: to.name,
      isAudio: isAudio,
      receiverPic: to.profileImageUrl,
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
              CallScreen(call: call, currentUser: from, isAudio: isAudio),
        ),
      );
    }
  }
}
