import 'package:Dana/screens/auth/login.dart';
import 'package:Dana/screens/auth/register.dart';
import 'package:Dana/screens/auth/reset_password.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/appbar_widget.dart';
import 'package:Dana/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  static const String id = 'VerificationScreen';

  final bool? isPassword;

  VerificationScreen({this.isPassword});
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String? _otpController;

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
          bottomNavigationBar: Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
              child: ButtonWidget(
                title: 'Continue',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => widget.isPassword!
                              ? ResetPasswordScreen()
                              : LoginScreen()));
                },
                iconText: false,
              ),
            ),
          ),
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: AppBarWidget(title: 'Code\nVerification', leading: true)),
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Text(
                    'Enter the 6-digit code that was sent to Dana@gmail.com',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
