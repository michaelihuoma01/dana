import 'package:another_flushbar/flushbar.dart';
import 'package:code_field/code_field.dart';
import 'package:dana/screens/auth/verification.dart';
import 'package:dana/services/api/auth_service.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/utils/utility.dart';
import 'package:dana/widgets/appbar_widget.dart';
import 'package:dana/widgets/button_widget.dart';
import 'package:dana/widgets/custom_modal_progress_hud.dart';
import 'package:dana/widgets/dialog.dart';
import 'package:dana/widgets/textformfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String id = 'ForgotPasswordScreen';

  final bool isPassword;

  ForgotPasswordScreen({this.isPassword});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _email;
  bool _isLoading = false;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

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
                onPressed: () async {
                  print(_email);
                  try {
                    await _auth
                        .sendPasswordResetEmail(email: _email)
                        .then((value) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => ImageDialog());
                    });
                  } catch (err) {
                    Utility.showMessage(context,
                        bgColor: Colors.red,
                        message: err.message,
                        pulsate: false,
                        type: MessageTypes.error);
                  }
                },
                iconText: false,
              ),
            ),
          ),
          appBar: AppBar(
              title: Text('Reset Password',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
              iconTheme: IconThemeData(color: Colors.white),
              centerTitle: false,
              backgroundColor: Colors.transparent,
              brightness: Brightness.dark,
              elevation: 0),
          backgroundColor: Colors.transparent,
          body: CustomModalProgressHUD(
            inAsyncCall: _isLoading,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 25),
                  Text(
                    'You\'ll receive a link to reset your password',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 25),
                  TextFormFieldWidget(
                      hintText: 'Email address',
                      fillColor: Colors.white,
                      onChanged: (value) {
                        _email = value;
                      },
                      type: TextInputType.emailAddress),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
