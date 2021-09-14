import 'dart:io';
import 'dart:math';

import 'package:dana/models/user_model.dart';
import 'package:dana/screens/auth/login.dart';
import 'package:dana/screens/home.dart';
import 'package:dana/services/api/database_service.dart';
import 'package:dana/services/api/storage_service.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/utils/utility.dart';
import 'package:dana/widgets/appbar_widget.dart';
import 'package:dana/widgets/button_widget.dart';
import 'package:dana/widgets/custom_modal_progress_hud.dart';
import 'package:dana/widgets/image_portrait.dart';
import 'package:dana/widgets/textformfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  static const String id = 'RegisterScreen';
  final String userId;

  final AppUser user;
  final Function updateUser;

  RegisterScreen({this.user, this.userId, this.updateUser});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  FirebaseDynamicLinks dynamicLinks;

  final picker = ImagePicker();
  String _imagePath;
  int radInt;
  TextEditingController pinController = new TextEditingController();
  TextEditingController dobController = new TextEditingController();
  TextEditingController genderController = new TextEditingController();

  FirebaseAuth firebaseUser = FirebaseAuth.instance;

  String _name = '';
  String _bio = '';
  String _gender = '';
  String _dob = '';

  File _profileImage;
  Locale myLocale;

  @override
  void initState() {
    super.initState();
    generateRandomNumber(9999999);
    checkPermissions();
    // _name = widget.user.name;
    // _bio = widget.user.bio;
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        Navigator.pushNamed(context, deepLink.path);
        FirebaseAuth auth = FirebaseAuth.instance;

        var actionCode = deepLink.queryParameters['oobCode'];

        try {
          await auth.checkActionCode(actionCode);
          await auth.applyActionCode(actionCode);

          // If successful, reload the user:
          auth.currentUser.reload();
          print('----------successful');
        } catch (e) {
          if (e.code == 'invalid-action-code') {
            print('The code is invalid.');
          }
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  generateRandomNumber(int max) {
    var randomGenerator = Random();
    setState(() {
      radInt = randomGenerator.nextInt(max);

      pinController.text = radInt.toString();
    });
    print(radInt);
  }

  updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    //Database Update
    String _profileImageUrl = '';

    if (_profileImage == null) {
      _profileImageUrl = widget.user.profileImageUrl;
    } else {
      _profileImageUrl = await StroageService.uploadUserProfileImage(
        widget.user.profileImageUrl,
        _profileImage,
      );
    }
    print(_profileImageUrl);

    AppUser user = AppUser(
        id: widget.userId,
        name: _name.trim(),
        pin: pinController.text,
        profileImageUrl: _profileImageUrl,
        bio: _bio.trim(),
        gender: _gender.trim(),
        dob: _dob,
        role: widget.user.role,
        isVerified: widget.user.isVerified);

    try {
      DatabaseService.updateUser(user);
      widget.updateUser(user);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(currentUserId: widget.userId)));
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

  Future pickImageFromGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);

    if (pickedFile != null) {
      print(pickedFile.path);
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  checkPermissions() async {
    var status = await Permission.photos.status;
    if (status.isGranted) {
      print('Permission granted');
    } else {
      Permission.photos.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    myLocale = Localizations.localeOf(context);
    print(myLocale.languageCode);
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
            bottomNavigationBar: Container(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
                child: ButtonWidget(
                  title: 'Continue',
                  onPressed: () {
                    if ((_name?.length ?? 0) < 3) {
                      Utility.showMessage(
                        context,
                        bgColor: Colors.red,
                        pulsate: false,
                        type: MessageTypes.error,
                        message: 'Name is too short',
                      );
                      return;
                    }

                    // if (!(_con.user.email?.contains('@') ?? false)) {
                    //   Utility.showMessage(_con.scaffoldKey.currentContext!,
                    //       message: 'Please enter a valid email address');
                    //   return;
                    // }
                    // if ((_con.user.password?.length ?? 0) < 8) {
                    //   Utility.showMessage(_con.scaffoldKey.currentContext!,
                    //       message: 'Password is too short');
                    //   return;
                    // }
                    // if (passwordController.text != _con.user.password) {
                    //   Utility.showMessage(_con.scaffoldKey.currentContext!,
                    //       message: 'Passwords do not match');
                    //   return;
                    // }
                    if (_bio == '') {
                      Utility.showMessage(context,
                          bgColor: Colors.red,
                          type: MessageTypes.error,
                          pulsate: false,
                          message: 'Please fill all fields');
                      return;
                    }
                    if (_gender == '') {
                      Utility.showMessage(context,
                          bgColor: Colors.red,
                          type: MessageTypes.error,
                          pulsate: false,
                          message: 'Please fill all fields');
                      return;
                    }
                    if (_dob == '') {
                      Utility.showMessage(context,
                          bgColor: Colors.red,
                          type: MessageTypes.error,
                          pulsate: false,
                          message: 'Please fill all fields');
                      return;
                    }
                    // if (_profileImage == null) {
                    //   Utility.showMessage(context,
                    //       bgColor: Colors.red,
                    //       pulsate: false,
                    //       type: MessageTypes.error,
                    //       message: 'Please choose a profile picture');
                    //   return;
                    // }

                    updateProfile();

                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  iconText: false,
                ),
              ),
            ),
            appBar: AppBar(
                title: Text('Setup your profile',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
                centerTitle: false,
                backgroundColor: Colors.transparent,
                brightness: Brightness.dark,
                automaticallyImplyLeading: false,
                elevation: 0),
            backgroundColor: Colors.transparent,
            key: _scaffoldKey,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: lightColor, width: 2),
                              borderRadius: BorderRadius.circular(100)),
                          height: 120,
                          width: 120,
                          child: _profileImage == null
                              ? Container(
                                  child: CircleAvatar(
                                    radius: 25.0,
                                    backgroundColor: Colors.grey,
                                    backgroundImage:
                                        AssetImage(placeHolderImageRef),
                                  ),
                                )
                              : Container(
                                  child: CircleAvatar(
                                    radius: 25.0,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: FileImage(_profileImage),
                                  ),
                                ),
                        ),
                        Positioned.fill(
                          child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(250))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                      onTap: () {
                                        pickImageFromGallery();
                                        print(_imagePath);
                                      },
                                      child: Icon(Icons.camera_alt_outlined,
                                          size: 20)),
                                ),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    TextFormFieldWidget(
                        hintText: 'Display name',
                        fillColor: Colors.white,
                        onChanged: (value) => _name = value,
                        type: TextInputType.name),
                    SizedBox(height: 25),
                    TextFormFieldWidget(
                        hintText: 'Bio',
                        fillColor: Colors.white,
                        onChanged: (value) => _bio = value,
                        type: TextInputType.name),
                    SizedBox(height: 25),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: DropdownButton(
                          hint: Text(
                            (_gender == '') ? 'Gender' : _gender,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          isExpanded: true,
                          iconSize: 30.0,
                          iconEnabledColor: lightColor,
                          iconDisabledColor: lightColor,
                          items: ['Male', 'Female', 'Other'].map(
                            (val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            },
                          ).toList(),
                          onChanged: (val) {
                            setState(
                              () {
                                _gender = val;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    GestureDetector(
                      onTap: () {
                        DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            minTime: DateTime(1920, 1, 1),
                            maxTime: DateTime(2030, 12, 31), onChanged: (date) {
                          print('change $date');
                        }, onConfirm: (date) {
                          var d12 = DateFormat('MM/dd/yyyy').format(date);
                          setState(() {
                            _dob = d12;
                            dobController.text = d12;
                          });
                          print('confirm $date');
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
                      },
                      child: TextFormFieldWidget(
                          hintText: 'Date of Birth',
                          fillColor: Colors.white,
                          enabled: false,
                          iconData: Icons.refresh,
                          prefixIconData: Icons.date_range,
                          onIconTap: () {},
                          controller: dobController,
                          type: TextInputType.name),
                    ),
                    SizedBox(height: 25),
                    Stack(
                      children: [
                        TextFormFieldWidget(
                            hintText: pinController.text,
                            // onChanged: (value) => _pin = value,
                            fillColor: Colors.white,
                            iconData: Icons.refresh,
                            prefixIconData: Icons.pin,
                            onIconTap: () {},
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            enabled: false),
                        Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Align(
                                alignment: (myLocale.languageCode == 'en')
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: IconButton(
                                    icon: Icon(Icons.refresh),
                                    color: lightColor,
                                    iconSize: 35,
                                    onPressed: () =>
                                        generateRandomNumber(9999999))))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
