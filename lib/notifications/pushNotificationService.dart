import 'dart:io';

import 'package:Dana/models/user_model.dart';
import 'package:Dana/services/api/auth_service.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  Future initialize(context) async {
    if (Platform.isIOS) {
      print('Initializing notifications');

      fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    var initialMessage = await FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print(message);
      }
    }).onError((error, stackTrace) {
      print(error);
    });

    if (initialMessage?.notification != null) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${initialMessage.data}');
      print(
          'Message also contained a notification: ${initialMessage.notification}');
      // fetchRideInfo(getRideID(initialMessage.data), context);
    } else {
      print(
          'Message also contained a notification: ${FirebaseMessaging.onMessage.first.toString()}');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('A new onMessage event was =========!');

      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification!.android;

      if (android != null) {
        print('A new onMessage event was published!');
        // fetchRideInfo(getRideID(message.data), context);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification!.android;
      print('A new onMessageOpenedApp event was  =========!');

      if (android != null) {
        print('A new onMessageOpenedApp event was published!');
        // fetchRideInfo(getRideID(message.data), context);
      }
    });

    FirebaseMessaging.onBackgroundMessage((message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification?.android;
      print('A new onBackgroundMessage event was =========!');

      if (android != null) {
        print('A new onBackgroundMessage event was published!');
        // fetchRideInfo(getRideID(message.data), context);
      }
      return Future<void>.value();
    });

    // fcm.configure(
    //     onMessage: (Map<String, dynamic> message) async {
    //       fetchRideInfo(getRideID(message), context);
    //     },
    //     onLaunch: (Map<String, dynamic> message) async {
    //       fetchRideInfo(getRideID(message), context);
    //     },
    //     onResume: (Map<String, dynamic> message) async {
    //       fetchRideInfo(getRideID(message), context);
    //     },
    //     onBackgroundMessage:
    //         Platform.isIOS ? null : onBackgroundMessageHandler);
  }

  Future<String?> getToken() async {
    String? token = await fcm.getToken();
    print('token: $token');

    final currentUser = _auth.currentUser!;

    final userDoc = await usersRef.doc(currentUser.uid).get();
    if (userDoc.exists) {
      AppUser user = AppUser.fromDoc(userDoc);
      if (token != user.token) {
        usersRef
            .doc(currentUser.uid)
            .set({'token': token}, SetOptions(merge: true));
      }
    }

    fcm.subscribeToTopic('allusers');
  }

  static String getRideID(Map<String, dynamic> message) {
    String rideID = '';

    if (Platform.isAndroid) {
      rideID = message['rideID'];
      print('rideID: $rideID');
    } else {
      rideID = message['rideID'];
      print('rideID: $rideID');
    }

    return rideID;
  }

  // static void fetchRideInfo(String rideID, context) {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) =>
  //         Loading(status: 'Getting ride details...'),
  //   );

  //   DatabaseReference rideRef =
  //       FirebaseDatabase.instance.reference().child('rideRequest/$rideID');
  //   print('getting notification here');

  //   rideRef.once().then((DataSnapshot snapshot) {
  //     Navigator.pop(context);
  //     if (snapshot.value != null) {
  //       // assetsAudioPlayer.open(Audio('sounds/alert.mp3'));
  //       // assetsAudioPlayer.play();

  //       double pickupLat = double.parse(
  //           snapshot.value['pickuplocation']['latitude'].toString());
  //       double pickupLng = double.parse(
  //           snapshot.value['pickuplocation']['longitude'].toString());
  //       String pickupAddress = snapshot.value['pickupAddress'].toString();

  //       double destinationLat =
  //           double.parse(snapshot.value['destination']['latitude'].toString());
  //       double destinationLng =
  //           double.parse(snapshot.value['destination']['longitude'].toString());
  //       String destinationAddress =
  //           snapshot.value['destinationAddress'].toString();

  //       String paymentMethod = snapshot.value['paymentMethod'].toString();
  //       String riderName = snapshot.value['riderName'];
  //       String riderPhone = snapshot.value['riderPhone'];
  //       String riderID = snapshot.value['riderID'];
  //       String deliveryMethod = snapshot.value['deliveryMethod'];
  //       String receiverName = snapshot.value['receiverName'].toString();
  //       String receiverPhone = snapshot.value['receiverPhone'].toString();

  //       TripDetails tripDetails = TripDetails();

  //       tripDetails.rideID = rideID;
  //       tripDetails.pickupAddress = pickupAddress;
  //       tripDetails.destinationAddress = destinationAddress;
  //       tripDetails.pickup = LatLng(pickupLat, pickupLng);
  //       tripDetails.destination = LatLng(destinationLat, destinationLng);
  //       tripDetails.paymentMethod = paymentMethod;
  //       tripDetails.riderName = riderName;
  //       tripDetails.riderPhone = riderPhone;
  //       tripDetails.riderID = riderID;
  //       tripDetails.deliveryMethod = deliveryMethod;
  //       tripDetails.receiverName = receiverName;
  //       tripDetails.receiverPhone = receiverPhone;

  //       print(tripDetails.rideID);
  //       print(tripDetails.pickupAddress);
  //       print(tripDetails.destinationAddress);
  //       print(tripDetails.pickup);
  //       print(tripDetails.destination);
  //       print(tripDetails.paymentMethod);

  //       showDialog(
  //         barrierDismissible: false,
  //         context: context,
  //         builder: (BuildContext context) =>
  //             NotificationDialog(tripDetails: tripDetails),
  //       );
  //     }
  //   }).onError((error, stackTrace) {
  //     print('-------------$error /////////// $stackTrace');
  //   });
  // }
}
