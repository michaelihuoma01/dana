// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();

  static late S current;

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();

      return S.current;
    });
  }

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Email`
  String get formFieldEmail {
    return Intl.message(
      'Email',
      name: 'formFieldEmail',
      desc: '',
      args: [],
    );
  }

  String get formFieldPassword {
    return Intl.message(
      'Password',
      name: 'formFieldPassword',
      desc: '',
      args: [],
    );
  }

  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  String get noAccount {
    return Intl.message(
      'Don\'t have an account yet?',
      name: 'noAccount',
      desc: '',
      args: [],
    );
  }

  String get signUp {
    return Intl.message(
      'Sign Up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Change Language`
  String get formFieldChangeLanguage {
    return Intl.message(
      'Change Language',
      name: 'formFieldChangeLanguage',
      desc: '',
      args: [],
    );
  }

  String get passwordLink {
    return Intl.message(
      'You\'ll receive a link to reset your password',
      name: 'passwordLink',
      desc: '',
      args: [],
    );
  }

  String get continueBtn {
    return Intl.message(
      'Continue',
      name: 'continueBtn',
      desc: '',
      args: [],
    );
  }

  String get chooseEmail {
    return Intl.message(
      'Choose your \nemail and password',
      name: 'chooseEmail',
      desc: '',
      args: [],
    );
  }

  String get getStarted {
    return Intl.message(
      'Let\'s get you started with your account',
      name: 'getStarted',
      desc: '',
      args: [],
    );
  }

  String get setupProfile {
    return Intl.message(
      'Setup your profile',
      name: 'setupProfile',
      desc: '',
      args: [],
    );
  }

  String get displayName {
    return Intl.message(
      'Display name',
      name: 'displayName',
      desc: '',
      args: [],
    );
  }

  String get bio {
    return Intl.message(
      'Bio',
      name: 'bio',
      desc: '',
      args: [],
    );
  }

  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  String get dob {
    return Intl.message(
      'Date of Birth',
      name: 'dob',
      desc: '',
      args: [],
    );
  }

  String get feeds {
    return Intl.message(
      'Feeds',
      name: 'feeds',
      desc: '',
      args: [],
    );
  }

  String get messages {
    return Intl.message(
      'Messages',
      name: 'messages',
      desc: '',
      args: [],
    );
  }

  String get calls {
    return Intl.message(
      'Calls',
      name: 'calls',
      desc: '',
      args: [],
    );
  }

  String get friends {
    return Intl.message(
      'Friends',
      name: 'friends',
      desc: '',
      args: [],
    );
  }

  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  String get tandc {
    return Intl.message(
      'Terms and Privacy Policy',
      name: 'tandc',
      desc: '',
      args: [],
    );
  }

  String get report {
    return Intl.message(
      'Report Issue',
      name: 'report',
      desc: '',
      args: [],
    );
  }

  String get private {
    return Intl.message(
      'Private Account',
      name: 'private',
      desc: '',
      args: [],
    );
  }

  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  String get contact {
    return Intl.message(
      'Contact us',
      name: 'contact',
      desc: '',
      args: [],
    );
  }

  String get describe {
    return Intl.message(
      'Please describe your issue',
      name: 'describe',
      desc: '',
      args: [],
    );
  }

  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  String get edit {
    return Intl.message(
      'Edit Profile',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  String get pin {
    return Intl.message(
      'Pin',
      name: 'pin',
      desc: '',
      args: [],
    );
  }

  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  String get searchby {
    return Intl.message(
      'Search by pin',
      name: 'searchby',
      desc: '',
      args: [],
    );
  }

  String get request {
    return Intl.message(
      'Request',
      name: 'request',
      desc: '',
      args: [],
    );
  }

  String get norequest {
    return Intl.message(
      'You have no friend request',
      name: 'norequest',
      desc: '',
      args: [],
    );
  }

  String get incoming {
    return Intl.message(
      'Incoming',
      name: 'incoming',
      desc: '',
      args: [],
    );
  }

  String get outgoing {
    return Intl.message(
      'Outgoing',
      name: 'outgoing',
      desc: '',
      args: [],
    );
  }

  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  String get added {
    return Intl.message(
      'added you as a friend',
      name: 'added',
      desc: '',
      args: [],
    );
  }

  String get liked {
    return Intl.message(
      'liked your post',
      name: 'added',
      desc: '',
      args: [],
    );
  }

  String get commented {
    return Intl.message(
      'commented on your post',
      name: 'added',
      desc: '',
      args: [],
    );
  }

  String get cam {
    return Intl.message(
      'Camera',
      name: 'cam',
      desc: '',
      args: [],
    );
  }

  String get post {
    return Intl.message(
      'Post',
      name: 'post',
      desc: '',
      args: [],
    );
  }

  String get happening {
    return Intl.message(
      'Whats happening?',
      name: 'happening',
      desc: '',
      args: [],
    );
  }

  String get broadcast {
    return Intl.message(
      'Broadcast Message',
      name: 'broadcast',
      desc: '',
      args: [],
    );
  }

  String get creategroup {
    return Intl.message(
      'Create Group',
      name: 'creategroup',
      desc: '',
      args: [],
    );
  }

  String get notif {
    return Intl.message(
      'Notifications',
      name: 'notif',
      desc: '',
      args: [],
    );
  }

  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  String get accept {
    return Intl.message(
      'Accept',
      name: 'accept',
      desc: '',
      args: [],
    );
  }

  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  String get nopost {
    return Intl.message(
      'No post yet',
      name: 'nopost',
      desc: '',
      args: [],
    );
  }

  String get userprivate {
    return Intl.message(
      'This user account is private',
      name: 'userprivate',
      desc: '',
      args: [],
    );
  }

  String get lastseen {
    return Intl.message(
      'Last seen',
      name: 'lastseen',
      desc: '',
      args: [],
    );
  }

  String get tap {
    return Intl.message(
      'Tap for photo & hold to record',
      name: 'tap',
      desc: '',
      args: [],
    );
  }

  String get story {
    return Intl.message(
      'Story',
      name: 'story',
      desc: '',
      args: [],
    );
  }

  String get editphoto {
    return Intl.message(
      'Edit Photo',
      name: 'editphoto',
      desc: '',
      args: [],
    );
  }

  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  String get newpost {
    return Intl.message(
      'New Post',
      name: 'newpost',
      desc: '',
      args: [],
    );
  }

  String get location {
    return Intl.message(
      'Where was this photo taken?',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  String get caption {
    return Intl.message(
      'Write a caption...',
      name: 'caption',
      desc: '',
      args: [],
    );
  }

  String get attach {
    return Intl.message(
      'Sent an attachment',
      name: 'attach',
      desc: '',
      args: [],
    );
  }

  String get chatcreated {
    return Intl.message(
      'Chat Created',
      name: 'chatcreated',
      desc: '',
      args: [],
    );
  }

  String get youadd {
    return Intl.message(
      'You were added',
      name: 'youadd',
      desc: '',
      args: [],
    );
  }

  String get nouser {
    return Intl.message(
      'No Users found! Please try again',
      name: 'nouser',
      desc: '',
      args: [],
    );
  }

  String get entermsg {
    return Intl.message(
      'Enter message',
      name: 'entermsg',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
      Locale.fromSubtags(languageCode: 'ar', countryCode: 'SA'),
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}
