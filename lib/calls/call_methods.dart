import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/calls/call.dart';
import 'package:Dana/calls/constants/strings.dart';

class CallMethods {
  final CollectionReference callCollection =
      FirebaseFirestore.instance.collection(CALL_COLLECTION);

  Stream<DocumentSnapshot> callStream({String? uid}) =>
      callCollection.doc(uid).snapshots();

        Future<DocumentSnapshot> joinCall({String? uid}) =>
      callCollection.doc(uid).get();

  Future<bool> makeCall({required Call call}) async {
    try {
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);

      await callCollection.doc(call.callerId).set(hasDialledMap);
      await callCollection.doc(call.receiverId).set(hasNotDialledMap);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  //   Future<bool> makeMultipleCall({required Call call}) async {
  //   try {
  //     call.hasDialled = true;
  //     Map<String, dynamic> hasDialledMap = call.toMap(call);

  //     call.hasDialled = false;
  //     Map<String, dynamic> hasNotDialledMap = call.toMap(call);

  //     await callCollection.doc(call.callerId).set(hasDialledMap);
  //     await callCollection.doc(call.receiverId).set(hasNotDialledMap);

  //     return true;
  //   } catch (e) {
  //     print(e);
  //     return false;
  //   }
  // }

  Future<bool> endCall(
      {required Call call,
      String? duration,
      Timestamp? timestamp,
      bool? isMissed}) async {
    try {
      await callCollection.doc(call.callerId).delete();
      await callCollection.doc(call.receiverId).delete();

      if (isMissed == false) {
        call.hasDialled = true;
      } else {
        call.hasDialled = null;
      }
      Map<String, dynamic> hasDialledMap = call.toMap(call);
      hasDialledMap["duration"] = duration;
      hasDialledMap["timestamp"] = timestamp;
      hasDialledMap["isMissed"] = isMissed;

      if (isMissed == false) {
        call.hasDialled = false;
      } else {
        call.hasDialled = null;
      }
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);
      hasNotDialledMap["duration"] = duration;
      hasNotDialledMap["timestamp"] = timestamp;
      hasNotDialledMap["isMissed"] = isMissed;

      await FirebaseFirestore.instance
          .collection('calls')
          .doc(call.callerId)
          .collection('callHistory')
          .add(hasDialledMap)
          .then((value) {
        FirebaseFirestore.instance
            .collection('calls')
            .doc(call.callerId)
            .collection('callHistory')
            .doc(value.id)
            .update({"id": value.id});
      });

      await FirebaseFirestore.instance
          .collection('calls')
          .doc(call.receiverId)
          .collection('callHistory')
          .add(hasNotDialledMap)
          .then((value) {
        FirebaseFirestore.instance
            .collection('calls')
            .doc(call.receiverId)
            .collection('callHistory')
            .doc(value.id)
            .update({"id": value.id});
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
