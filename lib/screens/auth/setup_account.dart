import 'dart:math';

import 'package:Dana/generated/l10n.dart';
import 'package:Dana/services/api/auth_service.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/utils/utility.dart';
import 'package:Dana/widgets/appbar_widget.dart';
import 'package:Dana/widgets/button_widget.dart';
import 'package:Dana/widgets/custom_modal_progress_hud.dart';
import 'package:Dana/widgets/textformfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SetupAccount extends StatefulWidget {
  static const String id = 'SetupAccount';

  final bool? isPassword;

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
    } catch (err) {
      Utility.showMessage(context,
          bgColor: Colors.red,
          message: err.toString(),
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
                  title: S.of(context)!.continueBtn,
                  onPressed: () {
                    registerUser();
                  },
                  iconText: false,
                ),
              ),
            ),
            appBar: AppBar(
                title: Text(S.of(context)!.chooseEmail,
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
                      S.of(context)!.getStarted,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 45),
                    TextFormFieldWidget(
                        hintText: S.of(context)!.formFieldEmail,
                        fillColor: Colors.white,
                        onChanged: (value) => _inputEmail = value,
                        type: TextInputType.emailAddress),
                    SizedBox(height: 20),
                    TextFormFieldWidget(
                        hintText: S.of(context)!.formFieldPassword,
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
