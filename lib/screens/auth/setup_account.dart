import 'dart:math';

import 'package:dana/services/api/auth_service.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/utils/utility.dart';
import 'package:dana/widgets/appbar_widget.dart';
import 'package:dana/widgets/button_widget.dart';
import 'package:dana/widgets/custom_modal_progress_hud.dart';
import 'package:dana/widgets/textformfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SetupAccount extends StatefulWidget {
  static const String id = 'SetupAccount';

  final bool isPassword;

  SetupAccount({this.isPassword});

  @override
  _SetupAccountState createState() => _SetupAccountState();
}

class _SetupAccountState extends State<SetupAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  String _inputEmail = '';
  String _inputPassword = '';

  @override
  void initState() {
    super.initState();
  }

  void registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signUpUser(
          context, _inputEmail.trim(), _inputPassword.trim());
    }  catch (err) {
 Utility.showMessage(context,
          bgColor: Colors.red,
          message: err.message,
          pulsate: false,
          type: MessageTypes.error);
      setState(() {
        _isLoading = false;
      });
      throw (err);
    }

    setState(() {
      _isLoading = false;
    });
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
        CustomModalProgressHUD(
          inAsyncCall: _isLoading,
          child: Scaffold(
            key: _scaffoldKey,
            bottomNavigationBar: Container(
              color: Colors.transparent,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
                child: ButtonWidget(
                  title: 'Continue',
                  onPressed: () {
                    registerUser();
                  },
                  iconText: false,
                ),
              ),
            ),
            appBar: AppBar(
                title: Text('Choose your \nemail and password',
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
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25),
                    Text(
                      'Let\'s get you started with your account',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 45),
                    TextFormFieldWidget(
                        hintText: 'Email address',
                        fillColor: Colors.white,
                        onChanged: (value) => _inputEmail = value,
                        type: TextInputType.emailAddress),
                    SizedBox(height: 20),
                    TextFormFieldWidget(
                        hintText: 'Password',
                        fillColor: Colors.white,
                        obscureText: true,
                        onChanged: (value) => _inputPassword = value,
                        type: TextInputType.visiblePassword),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
