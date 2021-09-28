import 'package:cloud_firestore/cloud_firestore.dart';

class Call {
  String? callerId;
  String? callerName;
  String? callerPic;
  String? receiverId;
  String? receiverName;
  String? receiverPic;
  String? channelId;
  String? duration;
  Timestamp? timestamp;
  bool? hasDialled;
  bool? isMissed;
  bool? isAudio;

  Call(
      {this.callerId,
      this.callerName,
      this.callerPic,
      this.receiverId,
      this.receiverName,
      this.receiverPic,
      this.channelId,
      this.hasDialled,
      this.duration,
      this.isMissed,
      this.timestamp,
      this.isAudio});

  // to map
  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = Map();
    callMap["caller_id"] = call.callerId;
    callMap["caller_name"] = call.callerName;
    callMap["caller_pic"] = call.callerPic;
    callMap["receiver_id"] = call.receiverId;
    callMap["receiver_name"] = call.receiverName;
    callMap["receiver_pic"] = call.receiverPic;
    callMap["channel_id"] = call.channelId;
    callMap["has_dialled"] = call.hasDialled;
    callMap["duration"] = call.duration;
    callMap["timestamp"] = call.timestamp;
    callMap["isMissed"] = call.isMissed;
    callMap["isAudio"] = call.isAudio;

    return callMap;
  }

  Call.fromMap(var callMap) {
    this.callerId = callMap["caller_id"];
    this.callerName = callMap["caller_name"];
    this.callerPic = callMap["caller_pic"];
    this.receiverId = callMap["receiver_id"];
    this.receiverName = callMap["receiver_name"];
    this.receiverPic = callMap["receiver_pic"];
    this.channelId = callMap["channel_id"];
    this.hasDialled = callMap["has_dialled"];
    this.duration = callMap["duration"];
    this.isMissed = callMap["isMissed"];
    this.timestamp = callMap["timestamp"];
    this.isAudio = callMap["isAudio"];
  }
}
