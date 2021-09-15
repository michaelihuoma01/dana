import 'package:camera/camera.dart';
import 'package:dana/models/user_model.dart';
import 'package:dana/screens/home.dart';
import 'package:dana/screens/pages/user_profile.dart';
import 'package:dana/utilities/show_error_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomNavigation {
  static void navigateToUserProfile(
      {required BuildContext context,
      bool? isCameFromBottomNavigation,
      String? currentUserId,
      AppUser? appUser, 
      String? userId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfile(
          // isCameFromBottomNavigation: isCameFromBottomNavigation,
          currentUserId: currentUserId,
          userId: userId,
          appUser: appUser,
          // goToCameraScreen: () =>
          //     navigateToHomeScreen(context, currentUserId, initialPage: 0),
        ),
      ),
    );
  }

  // static void navigateToShowErrorDialog(
  //     BuildContext context, String errorMessage) {
  //   Navigator.push(context,
  //       MaterialPageRoute(builder: (_) => ShowErrorDialog(errorMessage)));
  // }
  static Future<List<CameraDescription>?> getCameras(
      BuildContext context) async {
    List<CameraDescription>? _cameras;
    try {
      _cameras = await availableCameras();
    } on CameraException catch (_) {
      ShowErrorDialog.showAlertDialog(
          errorMessage: 'Cant get cameras!', context: context);
    }

    return _cameras;
  }

  static void navigateToHomeScreen(BuildContext context, String? currentUserId,
      {int initialPage = 1}) async {
    List<CameraDescription>? _cameras;
    if (initialPage == 0) {
      _cameras = await getCameras(context);
      if (_cameras == null) {
        return;
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            currentUserId: currentUserId,
            initialPage: initialPage,
            cameras: _cameras,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            currentUserId: currentUserId,
            initialPage: initialPage,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }
}
