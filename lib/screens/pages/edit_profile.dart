import 'dart:io';
import 'dart:math';

import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/auth/login.dart';
import 'package:Dana/screens/home.dart';
import 'package:Dana/services/api/database_service.dart';
import 'package:Dana/services/api/storage_service.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/utils/utility.dart';
import 'package:Dana/widgets/appbar_widget.dart';
import 'package:Dana/widgets/button_widget.dart';
import 'package:Dana/widgets/custom_modal_progress_hud.dart';
import 'package:Dana/widgets/image_portrait.dart';
import 'package:Dana/widgets/textformfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:switcher_button/switcher_button.dart';

class EditProfile extends StatefulWidget {
  static const String id = 'RegisterScreen';
  final String? userId;

  final AppUser? user;
  final Function? updateUser;

  EditProfile({this.user, this.userId, this.updateUser});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  final picker = ImagePicker();
  String? _imagePath;
  int? radInt;
  TextEditingController pinController = new TextEditingController();

  FirebaseAuth firebaseUser = FirebaseAuth.instance;

  

  String _name = '';
  String _bio = '';
  String? _pin = '';
  bool? _isPublic;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.user!.isPublic;
    checkPermissions();
  }

  updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    //Database Update
    String? _profileImageUrl = '';

    if (_profileImage == null) {
      _profileImageUrl = widget.user!.profileImageUrl;
    } else {
      _profileImageUrl = await StroageService.uploadUserProfileImage(
        widget.user!.profileImageUrl!,
        _profileImage!,
      );
    }
    print(_profileImageUrl);

    AppUser user = AppUser(
        id: widget.userId,
        name: (_name == '') ? widget.user!.name : _name.trim(),
        pin: _pin!.trim(),
        profileImageUrl: _profileImageUrl,
        bio: (_bio == '') ? widget.user!.bio : _bio.trim(),
        role: widget.user!.role,
        isPublic: _isPublic,
        isVerified: widget.user!.isVerified);

    try {
      DatabaseService.updateUser(user);
      widget.updateUser!(user);

      usersRef
          .doc(user.id)
          .update({'isPublic': (_isPublic == true) ? false : true});

      Utility.showMessage(context,
          message: 'Profile updated',
          pulsate: false,
          bgColor: Colors.green[600]!);
    } catch (err) {
      print(err.toString());
      Utility.showMessage(context,
          message: err.toString(),
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
              return PickupLayout(
                currentUser: widget.user,
                scaffold: Scaffold(
                  bottomNavigationBar: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 50, left: 20, right: 20),
                      child: ButtonWidget(
                        title: S.of(context)!.save,
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
                          title: S.of(context)!.edit,
                          isTab: false,
                          leading: true)),
                  backgroundColor: Colors.transparent,
                  key: _scaffoldKey,
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
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
                                                    user.profileImageUrl!),
                                          ),
                                        )
                                      : Container(
                                          child: CircleAvatar(
                                            radius: 25.0,
                                            backgroundColor: Colors.grey,
                                            backgroundImage:
                                                FileImage(_profileImage!),
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
                          Text(S.of(context)!.displayName,
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
                          Text(S.of(context)!.bio,
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
                          Text('PIN',
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
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(S.of(context)!.private,
                                  style:
                                      TextStyle(color: Colors.white, fontSize: 20)),
                                      SwitcherButton(
                            onColor: lightColor,
                            offColor: Colors.grey,
                            size: 40,
                            value: user.isPublic! ? false : true,
                            onChange: (value) {
                              _isPublic = value;
                              setState(() {});
                              print(value);
                            },
                          )
                            ],
                          ), 
                          
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })
      ],
    );
  }
}
