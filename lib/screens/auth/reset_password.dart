import 'package:Dana/screens/auth/login.dart';
import 'package:Dana/screens/auth/verification.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/appbar_widget.dart';
import 'package:Dana/widgets/button_widget.dart';
import 'package:Dana/widgets/textformfield_widget.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String id = 'ResetPasswordScreen';

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                iconText: false,
              ),
            ),
          ),
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: AppBarWidget(title: 'Reset\nPassword', leading: true)),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25),
                Text(
                  'Enter your new password here. \nTry not to forget it this time',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 45),
                TextFormFieldWidget(
                    hintText: 'New Password',
                    fillColor: Colors.white,
                    obscureText: true),
                SizedBox(height: 35),
                TextFormFieldWidget(
                  hintText: 'Confirm Password',
                  fillColor: Colors.white,
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
