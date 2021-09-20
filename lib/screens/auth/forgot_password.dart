import 'package:another_flushbar/flushbar.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/screens/auth/verification.dart';
import 'package:Dana/services/api/auth_service.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/utils/utility.dart';
import 'package:Dana/widgets/appbar_widget.dart';
import 'package:Dana/widgets/button_widget.dart';
import 'package:Dana/widgets/custom_modal_progress_hud.dart';
import 'package:Dana/widgets/dialog.dart';
import 'package:Dana/widgets/textformfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String id = 'ForgotPasswordScreen';

  final bool? isPassword;

  ForgotPasswordScreen({this.isPassword});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String? _email;
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
                title: S.of(context)!.continueBtn,
                onPressed: () async {
                  print(_email);
                  try {
                    await _auth
                        .sendPasswordResetEmail(email: _email!)
                        .then((value) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => ImageDialog());
                    });
                  } catch (err) {
                    Utility.showMessage(context,
                        bgColor: Colors.red,
                        message: err.toString(),
                        pulsate: false,
                        type: MessageTypes.error);
                  }
                },
                iconText: false,
              ),
            ),
          ),
          appBar: AppBar(
              title: Text(S.of(context)!.forgotPassword,
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
                    S.of(context)!.passwordLink,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 25),
                  TextFormFieldWidget(
                      hintText: S.of(context)!.formFieldEmail,
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
