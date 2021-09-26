import 'dart:async';
import 'dart:io';

import 'package:Dana/generated/l10n.dart';
import 'package:Dana/localization/language_constants.dart';
import 'package:Dana/models/theme_notifier.dart';
import 'package:Dana/models/user_data.dart';
import 'package:Dana/notifications/pushNotificationService.dart';
import 'package:Dana/screens/auth/forgot_password.dart';
import 'package:Dana/screens/auth/setup_account.dart';
import 'package:Dana/screens/auth/login.dart';
import 'package:Dana/screens/auth/register.dart';
import 'package:Dana/screens/auth/reset_password.dart';
import 'package:Dana/screens/auth/verification.dart';
import 'package:Dana/screens/home.dart';
import 'package:Dana/screens/pages/edit_profile.dart';
import 'package:Dana/screens/splash_screen.dart';
import 'package:Dana/utilities/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserData>(create: (context) => UserData())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
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
    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
    _listenToNotifications();

    super.initState();
  }

  void _listenToNotifications() async {
    FirebaseMessaging.onMessage.listen((message) {
      print('On message: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('On messageOpenedApp: $message');
    });

    FirebaseMessaging.onBackgroundMessage((message) {
      print('On onBackgroundMessage: $message');
      return Future<void>.value();
    }); 
  }

  Widget _getScreenId() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !_isTimerDone) {
          return SplashScreen();
        }
        if (snapshot.hasData && _isTimerDone) {
          Provider.of<UserData>(context, listen: false).currentUserId =
              snapshot.data!.uid;
          return HomeScreen(
            currentUserId: snapshot.data!.uid,
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }

  Locale? _locale;
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
    if (this._locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color?>(Colors.purple[800])),
        ),
      );
    } else {
      return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
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
            if (supportedLocale.languageCode == locale!.languageCode &&
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
