import 'dart:io';

import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/themes.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/contact_tile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  final SearchFrom searchFrom;
  final File? imageFile;
  AppUser? currentUser;

  CreateGroup({required this.searchFrom, this.currentUser, this.imageFile});

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot>? _users;
  String _searchText = '';
  List<AppUser> _userFollowing = [];
  List<AppUser?> _selectedUsers = [];

  List<bool> _userFollowingState = [];
  int _followingCount = 0;
  bool _isLoading = false;
  bool _selectAll = false;
  File? _profileImage;
  final picker = ImagePicker();
  String? _imagePath;
  String? imageUrl =
      'https://cdn4.iconfinder.com/data/icons/social-media-3/512/User_Group-512.png';

  final TextEditingController textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<Chat> startGroup() async {
    imageUrl = await StroageService.uploadMessageImage(_profileImage!);
    
    _selectedUsers.add(widget.currentUser);

    Timestamp timestamp = Timestamp.now();
    Map<String?, dynamic> readStatus = {};

    readStatus[widget.currentUser!.id] = false;

    for (AppUser? user in _selectedUsers) {
      readStatus[user!.id] = false;
    }

    String groupName = textEditingController.text;
    // _profileImageUrl

    DocumentReference res = await chatsRef.add({
      'groupName': groupName,
      'admin': widget.currentUser!.id,
      'groupUrl': imageUrl,
      'memberIds': _selectedUsers.map((item) => item!.id).toList(),
      'recentMessage': 'Chat Created',
      'recentSender': '',
      'recentTimestamp': timestamp,
      'readStatus': readStatus
    });

    Navigator.pop(context);

    return Chat(
      id: res.id,
      recentMessage: 'Chat Created',
      admin: widget.currentUser!.id,
      groupName: groupName,
      groupUrl: imageUrl,
      recentSender: '',
      recentTimestamp: timestamp,
      memberIds: _selectedUsers.map((item) => item!.id).toList(),
      readStatus: readStatus,
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _selectedUsers.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setupAll();
  }

  _setupAll() async {
    setState(() {
      _isLoading = true;
    });
    await _setupFollowing();
    setState(() {
      _isLoading = false;
    });
  }

  Future _setupFollowing() async {
    setState(() {
      _isLoading = true;
    });

    int userFollowingCount =
        await DatabaseService.numFollowing(widget.currentUser!.id);
    if (!mounted) return;
    setState(() {
      _followingCount = userFollowingCount;
    });

    List<String> userFollowingIds =
        await DatabaseService.getUserFollowingIds(widget.currentUser!.id);

    List<AppUser> userFollowing = [];
    List<bool> userFollowingState = [];
    for (String userId in userFollowingIds) {
      AppUser user = await DatabaseService.getUserWithId(userId);
      userFollowingState.add(true);
      userFollowing.add(user);
    }
    setState(() {
      _userFollowingState = userFollowingState;
      _userFollowing = userFollowing;
      _followingCount = userFollowing.length;
      if (_followingCount != _followingCount) {
        setState(() => _followingCount = _followingCount);
      }
    });
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
        PickupLayout(
          currentUser: widget.currentUser,
          scaffold: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: AppBar(
                    actions: [
                      GestureDetector(
                        onTap: () {
                          if (_selectAll == false) {
                            _userFollowing.forEach((element) {
                              setState(() {
                                _selectedUsers.add(element);
                                _selectAll = true;
                              });
                            });
                          } else {
                            _userFollowing.forEach((element) {
                              setState(() {
                                _selectedUsers.remove(element);
                                _selectAll = false;
                              });
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15, left: 15),
                          child: Icon(Icons.done_all, color: lightColor),
                        ),
                      )
                    ],
                    title: Text(S.of(context)!.creategroup,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins-Regular')),
                    backgroundColor: darkColor,
                    centerTitle: true,
                    elevation: 5,
                    automaticallyImplyLeading: true,
                    iconTheme: IconThemeData(color: Colors.white),
                    brightness: Brightness.dark,
                  )),
              floatingActionButton: new FloatingActionButton(
                backgroundColor: lightColor,
                child: const Icon(Icons.done),
                mini: true,
                onPressed: () async {
                  startGroup();
                },
                elevation: 5,
                isExtended: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                              height: 70,
                              width: 70,
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
                                      padding: const EdgeInsets.all(4),
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: lightColor, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: lightColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                                  BorderSide(color: lightColor, width: 1)),
                          hintText: 'Group name',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: TextStyle(color: Colors.white),
                        cursorColor: lightColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        child: ListView.builder(
                          itemCount: _userFollowing.length,
                          itemBuilder: (BuildContext context, int index) {
                            AppUser follower = _userFollowing[index];
                            AppUser? filteritem = _selectedUsers.firstWhere(
                                (item) => item!.id == follower.id,
                                orElse: () => null);
                            return Theme(
                              data:
                                  ThemeData(unselectedWidgetColor: lightColor),
                              child: CheckboxListTile(
                                value: (_selectAll == true)
                                    ? true
                                    : filteritem != null,
                                checkColor: darkColor,
                                activeColor: lightColor,
                                selectedTileColor: lightColor,
                                title: Row(children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                    child: CircleAvatar(
                                      radius: 25.0,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: (follower
                                                  .profileImageUrl!.isEmpty
                                              ? AssetImage(placeHolderImageRef)
                                              : CachedNetworkImageProvider(
                                                  follower.profileImageUrl!))
                                          as ImageProvider<Object>?,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(follower.name!,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18)),
                                        Text('PIN: ${follower.pin}',
                                            maxLines: 3,
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  )
                                ]),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedUsers.add(follower);
                                    } else {
                                      _selectedUsers.removeWhere(
                                          (item) => item!.id == follower.id);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }
}
