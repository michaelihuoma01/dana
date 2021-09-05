import 'dart:async';

import 'package:dana/generated/l10n.dart';
import 'package:dana/localization/language_constants.dart';
import 'package:dana/models/theme_notifier.dart';
import 'package:dana/models/user_data.dart';
import 'package:dana/screens/auth/forgot_password.dart';
import 'package:dana/screens/auth/setup_account.dart';
import 'package:dana/screens/auth/login.dart';
import 'package:dana/screens/auth/register.dart';
import 'package:dana/screens/auth/reset_password.dart';
import 'package:dana/screens/auth/verification.dart';
import 'package:dana/screens/home.dart';
import 'package:dana/screens/pages/edit_profile.dart';
import 'package:dana/screens/splash_screen.dart';
import 'package:dana/utilities/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkMode') ?? false;

    //Set Navigation bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: darkModeOn ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness:
            darkModeOn ? Brightness.light : Brightness.dark));
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<UserData>(create: (context) => UserData()),
        ChangeNotifierProvider<ThemeNotifier>(
            create: (context) =>
                ThemeNotifier(darkModeOn ? darkTheme : lightTheme))
      ],
      child: MyApp(),
    ));
  });
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  bool _isTimerDone = false;

  @override
  void initState() {
    Timer(Duration(seconds: 3), () => setState(() => _isTimerDone = true));
    super.initState();
  }

  Widget _getScreenId() {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !_isTimerDone) {
          return SplashScreen();
        }
        if (snapshot.hasData && _isTimerDone) {
          Provider.of<UserData>(context, listen: false).currentUserId =
              snapshot.data.uid;
          return HomeScreen(
            currentUserId: snapshot.data.uid,
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }

  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if (this._locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[800])),
        ),
      );
    } else {
      return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.getTheme(),
        home: _getScreenId(),
        locale: _locale,
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        // initialRoute: LoginScreen.id,
        routes: {
          SplashScreen.id: (context) => SplashScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          RegisterScreen.id: (context) => RegisterScreen(),
          SetupAccount.id: (context) => SetupAccount(),
          ForgotPasswordScreen.id: (context) => ForgotPasswordScreen(),
          ResetPasswordScreen.id: (context) => ResetPasswordScreen(),
          VerificationScreen.id: (context) => VerificationScreen(),
          HomeScreen.id: (context) => HomeScreen(),
          EditProfile.id: (context) => EditProfile(),
        },
      );
    }
  }
}
