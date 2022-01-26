import 'dart:io';

import 'package:Dana/models/models.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/pages/direct_messages/nested_screens/full_screen_image.dart';
import 'package:Dana/services/api/auth_service.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/qrcode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

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

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('logo');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      // onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      // 'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print('A new onMessage event was =========!');

      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification!.android;

      if (android != null) {
        usersRef.doc(_auth.currentUser?.uid).update({'isVerified': true});
        print('A new onMessage event was =========!');

        // fetchRideInfo(getRideID(message.data), context);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification!.android;
      // print('A new onMessageOpenedApp event was  =========!');

      if (android != null) {
        print('A new onMessageOpenedApp event was published ${message.data}!');
        // fetchRideInfo(getRideID(message.data), context);
      }
    });

    FirebaseMessaging.onBackgroundMessage((message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification?.android;
      // print('A new onBackgroundMessage event was =========!');

      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                color: lightColor
                // icon: android.smallIcon,
                // other properties...
                ),
          ));

      if (android != null) {
        print('A new onBackgroundMessage event was ${message.data}!');
        // fetchRideInfo(getRideID(message.data), context);
      }
      return Future<void>.value();
    });
  }

  Future<String?> getToken(context) async {
    String? token = await fcm.getToken();

    String? currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserId;
    if (currentUserId != null) {
      final userDoc = await usersRef.doc(currentUserId).get();
      if (userDoc.exists) {
        AppUser user = AppUser.fromDoc(userDoc);
        if (token != user.token) {
          usersRef
              .doc(currentUserId)
              .set({'token': token}, SetOptions(merge: true));
        }
      }

      fcm.subscribeToTopic('allusers');
    }
  }

  static String getuserID(Map<String, dynamic> message) {
    String userID = '';

    if (Platform.isAndroid) {
      userID = message['rideID'];
      print('userID: $userID');
    } else {
      userID = message['rideID'];
      print('userID: $userID');
    }

    return userID;
  }
}
