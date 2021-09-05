import 'package:another_flushbar/flushbar.dart';
import 'package:dana/models/user_data.dart';
import 'package:dana/models/user_model.dart';
import 'package:dana/screens/auth/login.dart';
import 'package:dana/screens/auth/register.dart';
import 'package:dana/screens/home.dart';
import 'package:dana/services/api/database_service.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utils/shared_preferences_utils.dart';
import 'package:dana/utils/utility.dart';
import 'package:dana/widgets/button_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> signUpUser(
      BuildContext context, String email, String password) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User signedInUser = authResult.user;
      if (signedInUser != null) {
        String token = await _messaging.getToken();
        _firestore.collection('/users').doc(signedInUser.uid).set({
          'name': '',
          'email': email,
          'profileImageUrl': '',
          'token': token,
          'isVerified': false,
          'isBanned': false,
          'bio': '',
          'pin': '',
          'role': 'user',
          'lastSeenOnline': Timestamp.now(),
          'lastSeenOffline': Timestamp.now(),
          'status': '',
          'timeCreated': Timestamp.now(),
        }).then((value) async {
          Provider.of<UserData>(context, listen: false).currentUserId =
              signedInUser.uid;
          AppUser currentUser =
              await DatabaseService.getUserWithId(signedInUser.uid);

          SharedPreferencesUtil.setUserId(signedInUser.uid);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => RegisterScreen(
                      userId: signedInUser.uid,
                      user: currentUser,
                      updateUser: (AppUser updateUser) {
                        AppUser updatedUser = AppUser(
                          id: updateUser.id,
                          name: updateUser.name,
                          email: updateUser.email,
                          profileImageUrl: updateUser.profileImageUrl,
                          bio: updateUser.bio,
                          isVerified: updateUser.isVerified,
                          role: updateUser.role,
                        );

                        Provider.of<UserData>(context, listen: false)
                            .currentUser = updatedUser;

                        AuthService.updateTokenWithUser(updatedUser);
                      })),
              (Route<dynamic> route) => false);
        });
      }
    } catch (err) {
      Utility.showMessage(context,
          bgColor: Colors.red,
          message: err.message,
          pulsate: false,
          type: MessageTypes.error);
      throw (err);
    }
  }

  static Future<void> loginUser(
      BuildContext context, String email, String password) async {
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        User signedInUser = _auth.currentUser;

        Provider.of<UserData>(context, listen: false).currentUserId =
            signedInUser.uid;
        AppUser currentUser =
            await DatabaseService.getUserWithId(signedInUser.uid);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                      // currentUser: currentUser,
                      currentUserId: currentUser.id,
                    )),
            (Route<dynamic> route) => false);

        SharedPreferencesUtil.setUserId(signedInUser.uid);
      });
      SharedPreferencesUtil.setUserId(_auth.currentUser.uid);
    } catch (err) {
      throw (err);
    }
  }

  static Future<void> removeToken() async {
    final currentUser = _auth.currentUser.uid;
    await usersRef.doc(currentUser).set({'token': ''}, SetOptions(merge: true));
  }

  static Future<void> updateToken() async {
    final currentUser = _auth.currentUser;
    final token = await _messaging.getToken();
    final userDoc = await usersRef.doc(currentUser.uid).get();
    if (userDoc.exists) {
      AppUser user = AppUser.fromDoc(userDoc);
      if (token != user.token) {
        usersRef
            .doc(currentUser.uid)
            .set({'token': token}, SetOptions(merge: true));
      }
    }
  }

  static Future<void> updateTokenWithUser(AppUser user) async {
    final token = await _messaging.getToken();
    if (token != user.token) {
      await usersRef.doc(user.id).update({'token': token});
    }
  }

  static Future<void> logout(BuildContext context) async {
    // await removeToken();
    Future.wait([
      _auth.signOut().then((value) => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
          (Route<dynamic> route) => false))
    ]);
  }
}
