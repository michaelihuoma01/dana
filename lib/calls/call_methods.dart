import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/calls/call.dart';
import 'package:Dana/calls/constants/strings.dart';

class CallMethods {
  final CollectionReference callCollection =
      FirebaseFirestore.instance.collection(CALL_COLLECTION);

  Stream<DocumentSnapshot> callStream({String? uid}) =>
      callCollection.doc(uid).snapshots();

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

  Future<bool> endCall({required Call call}) async {
    try {
      await callCollection.doc(call.callerId).delete();
      await callCollection.doc(call.receiverId).delete();

      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);

      await FirebaseFirestore.instance
          .collection('calls')
          .doc(call.callerId)
          .collection('callHistory')
          .add(hasDialledMap);

      await FirebaseFirestore.instance
          .collection('calls')
          .doc(call.receiverId)
          .collection('callHistory')
          .add(hasNotDialledMap);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
