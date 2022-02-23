import 'package:cloud_firestore/cloud_firestore.dart';

class Call {
  String? callerId;
  String? callerName;
  String? callerPic;
  String? receiverId;
  String? secondReceiverId;
  String? thirdReceiverId;
  String? fourthReceiverId;
  String? receiverName;
  String? secondReceiverName;
  String? thirdReceiverName;
  String? fourthReceiverName;
  String? receiverPic;
  String? secondReceiverPic;
  String? thirdReceiverPic;
  String? fourthReceiverPic;
  String? channelId;
  String? duration;
  String? id;
  Timestamp? timestamp;
  bool? hasDialled;
  bool? isMissed;
  bool? isAudio;

  Call(
      {this.callerId,
      this.callerName,
      this.callerPic,
      this.receiverId,
      this.secondReceiverId,
      this.thirdReceiverId,
      this.fourthReceiverId,
      this.receiverName,
      this.secondReceiverName,
      this.thirdReceiverName,
      this.fourthReceiverName,
      this.receiverPic,
      this.secondReceiverPic,
      this.thirdReceiverPic,
      this.fourthReceiverPic,
      this.channelId,
      this.hasDialled,
      this.duration,
      this.isMissed,
      this.timestamp,
      this.id,
      this.isAudio});

  // to map
  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = Map();
    callMap["caller_id"] = call.callerId;
    callMap["caller_name"] = call.callerName;
    callMap["caller_pic"] = call.callerPic;
    callMap["receiver_id"] = call.receiverId;
    // callMap["second_receiver_id"] = call.secondReceiverId;
    // callMap["third_receiver_id"] = call.thirdReceiverId;
    callMap["receiver_name"] = call.receiverName;
    // callMap["second_receiver_name"] = call.secondReceiverName;
    // callMap["third_receiver_name"] = call.thirdReceiverName;
    callMap["receiver_pic"] = call.receiverPic;
    // callMap["second_receiver_pic"] = call.secondReceiverPic;
    // callMap["third_receiver_pic"] = call.thirdReceiverPic;
    callMap["channel_id"] = call.channelId;
    callMap["has_dialled"] = call.hasDialled;
    callMap["duration"] = call.duration;
    callMap["timestamp"] = call.timestamp;
    callMap["isMissed"] = call.isMissed;
    callMap["isAudio"] = call.isAudio;
    callMap["id"] = call.id;

    return callMap;
  }

  Call.fromMap(var callMap) {
    this.callerId = callMap["caller_id"];
    this.callerName = callMap["caller_name"];
    this.callerPic = callMap["caller_pic"];
    this.receiverId = callMap["receiver_id"];
    // this.secondReceiverId = callMap["second_receiver_id"];
    // this.thirdReceiverId = callMap["third_receiver_id"];
    this.receiverName = callMap["receiver_name"];
    // this.secondReceiverName = callMap["second_receiver_name"];
    // this.thirdReceiverName = callMap["third_receiver_name"];
    this.receiverPic = callMap["receiver_pic"];
    // this.secondReceiverName = callMap["second_receiver_pic"];
    // this.thirdReceiverName = callMap["third_receiver_pic"];
    this.channelId = callMap["channel_id"];
    this.hasDialled = callMap["has_dialled"];
    this.duration = callMap["duration"];
    this.isMissed = callMap["isMissed"];
    this.timestamp = callMap["timestamp"];
    this.isAudio = callMap["isAudio"];
    this.id = callMap["id"];
  }
}
