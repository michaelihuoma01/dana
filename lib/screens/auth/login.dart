import 'package:dana/classes/language.dart';
import 'package:dana/generated/l10n.dart';
import 'package:dana/localization/language_constants.dart';
import 'package:dana/main.dart';
import 'package:dana/screens/auth/forgot_password.dart';
import 'package:dana/screens/auth/register.dart';
import 'package:dana/screens/auth/setup_account.dart';
import 'package:dana/screens/home.dart';
import 'package:dana/services/api/auth_service.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/utils/utility.dart';
import 'package:dana/widgets/button_widget.dart';
import 'package:dana/widgets/custom_modal_progress_hud.dart';
import 'package:dana/widgets/textformfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _inputEmail = '';
  String _inputPassword = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void loginPressed() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });
    try {
      await AuthService.loginUser(
          context, _inputEmail.trim(), _inputPassword.trim());
    } catch (err) {
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

  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 130),
                  SizedBox(height: 30),
                  TextFormFieldWidget(
                      hintText: S.of(context).formFieldEmail,
                      onChanged: (value) => _inputEmail = value,
                      fillColor: Colors.white,
                      type: TextInputType.emailAddress),
                  SizedBox(height: 15),
                  TextFormFieldWidget(
                      hintText: S.of(context).formFieldPassword,
                      onChanged: (value) => _inputPassword = value,
                      obscureText: true,
                      fillColor: Colors.white),
                  SizedBox(height: 10),
                  Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ForgotPasswordScreen(isPassword: false)));
                        },
                        child: Text(S.of(context).forgotPassword,
                            style: TextStyle(
                                color: Colors.white,
                                // fontFamily: 'Poppins-Italic',
                                fontSize: 16)),
                      )),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: ButtonWidget(
                      title: S.of(context).login,
                      onPressed: () {
                        loginPressed();
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => HomeScreen()));
                      },
                      iconText: false,
                    ),
                  ),
                  // SizedBox(height: 40),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     ButtonWidget(
                  //       title: 'Login with Google',
                  //       onPressed: () {},
                  //       iconText: true,
                  //       icon: FaIcon(FontAwesomeIcons.google),
                  //       bgColor: Colors.lightBlue,
                  //       textColor: Colors.white,
                  //     ),
                  //     SizedBox(width: 5),
                  //     ButtonWidget(
                  //       title: 'Login with Apple',
                  //       onPressed: () {},
                  //       iconText: true,
                  //       bgColor: Colors.white,
                  //       textColor: Colors.black,
                  //       icon: FaIcon(FontAwesomeIcons.apple,
                  //           color: Colors.black),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${S.of(context).noAccount} ',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SetupAccount()));
                        },
                        child: Text('  ${S.of(context).signUp}',
                            style: TextStyle(
                                color: lightColor,
                                fontSize: 16,
                                fontFamily: 'Poppins-Bold')),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S.of(context).formFieldChangeLanguage,
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<Language>(
                          underline: SizedBox(),
                          icon: Icon(
                            Icons.language,
                            color: lightColor,
                          ),
                          onChanged: (Language language) {
                            _changeLanguage(language);
                          },
                          items: Language.languageList()
                              .map<DropdownMenuItem<Language>>(
                                (e) => DropdownMenuItem<Language>(
                                  value: e,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text(
                                        e.flag,
                                        style: TextStyle(fontSize: 30),
                                      ),
                                      Text(e.name)
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
