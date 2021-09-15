import 'package:dana/screens/auth/login.dart';
import 'package:dana/screens/home.dart';
import 'package:dana/services/services.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/utils/shared_preferences_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'SplashScreen';

  final String? currentUserId;
  SplashScreen({
    this.currentUserId,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkIfUserExists();
  }

  Future<void> checkIfUserExists() async {
    String? userId = await SharedPreferencesUtil.getUserId();
    Navigator.pop(context);
    if (userId != null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    // currentUser: currentUser,
                    currentUserId:userId,
                  )),
          (Route<dynamic> route) => false);
    } else {
      Navigator.pushNamed(context, LoginScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          color: darkColor,
          child: Image.asset(
            'assets/images/background.png',
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Image.asset('assets/images/logo.png', height: 150)),
                SizedBox(height: 50),
                SpinKitWanderingCubes(color: Colors.white, size: 40)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
