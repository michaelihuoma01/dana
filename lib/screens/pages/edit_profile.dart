import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  static const String id = 'RegisterScreen';
  final String userId;

  final AppUser user;
  final Function updateUser;

  EditProfile({this.user, this.userId, this.updateUser});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  final picker = ImagePicker();
  String _imagePath;
  int radInt;
  TextEditingController pinController = new TextEditingController();

  FirebaseAuth firebaseUser = FirebaseAuth.instance;

  String _name = '';
  String _bio = '';
  String _pin = '';
  File _profileImage;

  @override
  void initState() {
    super.initState();
    checkPermissions();
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
        name: (_name == '') ? widget.user.name : _name.trim(),
        pin: _pin.trim(),
        profileImageUrl: _profileImageUrl,
        bio: (_bio == '') ? widget.user.bio : _bio.trim(),
        role: widget.user.role,
        isVerified: widget.user.isVerified);

    try {
      DatabaseService.updateUser(user);
      widget.updateUser(user);

      Utility.showMessage(context,
          message: 'Profile updated',
          pulsate: false,
          bgColor: Colors.green[600]);
    } catch (err) {
      print(err.message);
      Utility.showMessage(context,
          message: err.message,
          pulsate: false,
          bgColor: Colors.red,
          type: MessageTypes.error);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future pickImageFromGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);

    if (pickedFile != null) {
      // _userRegistration.localProfilePhotoPath = pickedFile.path;
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
        FutureBuilder(
            future: usersRef.doc(widget.userId).get(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(color: lightColor),
                );
              }
              AppUser user = AppUser.fromDoc(snapshot.data);
              return Scaffold(
                bottomNavigationBar: Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 50, left: 20, right: 20),
                    child: ButtonWidget(
                      title: 'Save',
                      onPressed: () {
                        _pin = user.pin;
                        updateProfile();
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) => HomeScreen()));
                      },
                      iconText: false,
                    ),
                  ),
                ),
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: AppBarWidget(
                        title: 'Edit Profile', isTab: false, leading: true)),
                backgroundColor: Colors.transparent,
                key: _scaffoldKey,
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                height: 120,
                                width: 120,
                                child: _profileImage == null
                                    ? Container(
                                        child: CircleAvatar(
                                          radius: 25.0,
                                          backgroundColor: Colors.grey,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  user.profileImageUrl),
                                        ),
                                      )
                                    : Container(
                                        child: CircleAvatar(
                                          radius: 25.0,
                                          backgroundColor: Colors.grey,
                                          backgroundImage:
                                              FileImage(_profileImage),
                                        ),
                                      ),
                              ),
                              Positioned.fill(
                                child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(250))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                            onTap: () {
                                              pickImageFromGallery();
                                              print(_imagePath);
                                            },
                                            child: Icon(
                                                Icons.camera_alt_outlined,
                                                size: 20)),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Text('Name',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        SizedBox(height: 10),
                        TextFormFieldWidget(
                            hintText: 'Display name',
                            fillColor: Colors.white,
                            initialValue: user.name,
                            onChanged: (value) => _name = value,
                            type: TextInputType.name),
                        SizedBox(height: 25),
                        Text('Bio',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        SizedBox(height: 10),
                        TextFormFieldWidget(
                            hintText: 'Bio',
                            fillColor: Colors.white,
                            initialValue: user.bio,
                            onChanged: (value) => _bio = value,
                            type: TextInputType.name),
                        SizedBox(height: 25),
                        Text('Pin',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        SizedBox(height: 10),
                        TextFormFieldWidget(
                            hintText: user.pin,
                            fillColor: Colors.white,
                            iconData: Icons.refresh,
                            prefixIconData: Icons.pin,
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            enabled: false),
                      ],
                    ),
                  ),
                ),
              );
            })
      ],
    );
  }
}
