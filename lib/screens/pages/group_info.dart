import 'dart:io';

import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:Dana/screens/home.dart';
import 'package:Dana/screens/tabs/messages_screen.dart';
import 'package:Dana/utils/utility.dart';
import 'package:Dana/widgets/custom_modal_progress_hud.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/themes.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/contact_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupInfo extends StatefulWidget {
  final File? imageFile;
  AppUser? currentUser;
  List<AppUser?>? groupUsers;
  List<dynamic>? groupUserIds;
  String? admin, groupName, chatID;

  GroupInfo(
      {this.groupUsers,
      this.currentUser,
      this.admin,
      this.groupUserIds,
      this.groupName,
      this.chatID,
      this.imageFile});

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot>? _users;
  String _searchText = '';
  List<AppUser> _userFollowing = [];
  List<AppUser?> _selectedUsers = [];
  List<AppUser?> _friends = [];
  bool isFriends = false;

  bool _isLoading = false;

  TextEditingController textEditingController = TextEditingController();

  Future<Chat> createGroup() async {
    _selectedUsers.add(widget.currentUser);

    Timestamp timestamp = Timestamp.now();
    Map<String?, dynamic> readStatus = {};

    readStatus[widget.currentUser!.id] = false;

    for (AppUser? user in _selectedUsers) {
      readStatus[user!.id] = false;
    }

    String groupName = textEditingController.text;

    DocumentReference res = await chatsRef.add({
      'groupName': groupName,
      'admin': widget.currentUser!.id,
      // 'photoUrl': groupPhoto,

      'memberIds': _selectedUsers.map((item) => item!.id).toList(),
      'recentMessage': 'Chat Created',
      'recentSender': '',
      'recentTimestamp': timestamp,
      'readStatus': readStatus
    });
    _clearState();

    return Chat(
      id: res.id,
      recentMessage: 'Chat Created',
      admin: widget.currentUser!.id,
      groupName: groupName,
      recentSender: '',
      recentTimestamp: timestamp,
      memberIds: _selectedUsers.map((item) => item!.id).toList(),
      readStatus: readStatus,
    );
  }

  void _clearState() {
    _selectedUsers.clear();
    textEditingController.clear();
  }

  @override
  void dispose() {
    textEditingController.dispose();
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
    textEditingController.text = widget.groupName!;
    setState(() {
      _isLoading = false;
    });
  }

  Future _setupFollowing() async {
    setState(() {
      _isLoading = true;
    });

    List<AppUser> userFollowing = [];

    for (String? userId in widget.groupUserIds!) {
      

      AppUser user = await DatabaseService.getUserWithId(userId);

      userFollowing.add(user);
       
    }
    setState(() {
      _userFollowing = userFollowing;
    });

    List<String?> followingUsers =
        await DatabaseService.getUserFollowingIds(widget.currentUser?.id);

    List<String?> followerUsers =
        await DatabaseService.getUserFollowersIds(widget.currentUser?.id);

    var friendList = [...followingUsers, ...followerUsers].toSet().toList();

    for (String? userId in friendList) {
      var isFollowing = await DatabaseService.isUserFollower(
        currentUserId: widget.currentUser!.id,
        userId: userId,
      );

      var isFollower = await DatabaseService.isUserFollower(
        currentUserId: userId,
        userId: widget.currentUser!.id,
      );

      var friends = await DatabaseService.getUserWithId(userId);

      if (isFollower == true && isFollowing == true) {
        if (!widget.groupUserIds!.contains(friends.id)) {
          setState(() {
            isFriends = true;
            _friends.add(friends);
          });
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  addFriend() {
    print('|||||||||||||||${_friends.length}');

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Dialog(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: darkColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Choose Friends',
                            style: TextStyle(color: lightColor, fontSize: 20)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _friends.length,
                          itemBuilder: (BuildContext context, int index) {
                            AppUser? follower = _friends[index];
                            AppUser? filteritem = _selectedUsers.firstWhere(
                                (item) => item!.id == follower!.id,
                                orElse: () => null);
                            return Theme(
                              data:
                                  ThemeData(unselectedWidgetColor: lightColor),
                              child: GestureDetector(
                                onTap: () async {
                                  await chatsRef.doc(widget.chatID).update({
                                    'memberIds':
                                        FieldValue.arrayUnion([follower!.id])
                                  }).then((value) {
                                    Navigator.pop(context);

                                    Utility.showMessage(context,
                                        pulsate: false,
                                        bgColor: Colors.green,
                                        message: 'You added ${follower.name}');
                                  });
                                },
                                child: ListTile(
                                  title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(children: [
                                            Container(
                                              height: 40,
                                              width: 40,
                                              child: CircleAvatar(
                                                radius: 25.0,
                                                backgroundColor: Colors.grey,
                                                backgroundImage: (follower!
                                                            .profileImageUrl!
                                                            .isEmpty
                                                        ? AssetImage(
                                                            placeHolderImageRef)
                                                        : CachedNetworkImageProvider(
                                                            follower
                                                                .profileImageUrl!))
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
                                                      style: TextStyle(
                                                          color: Colors.grey)),
                                                ],
                                              ),
                                            )
                                          ]),
                                        ),
                                        Icon(Icons.add_sharp,
                                            color: lightColor, size: 22),
                                      ]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return CustomModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Stack(
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
                    title: Text('Edit Group',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins-Regular',
                            fontWeight: FontWeight.bold)),
                    backgroundColor: darkColor,
                    centerTitle: true,
                    elevation: 5,
                    automaticallyImplyLeading: true,
                    iconTheme: IconThemeData(color: Colors.white),
                    brightness: Brightness.dark,
                    actions: [
                      GestureDetector(
                        onTap: () {
                          addFriend();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.person_add, color: lightColor),
                        ),
                      )
                    ],
                  )),
              floatingActionButton: new FloatingActionButton(
                backgroundColor: lightColor,
                child: const Icon(Icons.done),
                onPressed: () {
                  print(textEditingController.text);
                  createGroup();
                  Navigator.pop(context);
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          hintText: 'Group name',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: TextStyle(color: Colors.white, fontSize: 23),
                        cursorColor: lightColor,
                      ),
                    ),
                    Divider(color: Colors.grey),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _userFollowing.length,
                        itemBuilder: (BuildContext context, int index) {
                          AppUser follower = widget.groupUsers![index]!;
                          // AppUser filteritem = _selectedUsers.firstWhere(
                          //     (item) => item.id == follower.id,
                          //     orElse: () => null);
                          return Column(
                            children: [
                              Row(children: [
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
                                  child: Row(
                                    children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('${follower.name} ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18)),
                                            SizedBox(height: 2),
                                            (widget.admin == follower.id)
                                                ? Text('Admin',
                                                    style: TextStyle(
                                                        color: lightColor,
                                                        fontSize: 15))
                                                : Text('PIN: ${follower.pin!}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15))
                                          ]),
                                      Spacer(),
                                      if (widget.admin ==
                                          widget.currentUser!.id)
                                        GestureDetector(
                                          onTap: () async {
                                            await chatsRef
                                                .doc(widget.chatID)
                                                .update({
                                              'admin': follower.id
                                            }).then((value) {
                                              Utility.showMessage(context,
                                                  pulsate: false,
                                                  bgColor: Colors.green,
                                                  message:
                                                      '${follower.name} is now the group admin');
                                            });
                                          },
                                          child: Icon(
                                              Icons.admin_panel_settings,
                                              color: lightColor,
                                              size: 23),
                                        ),
                                      SizedBox(width: 10),
                                      if (widget.admin ==
                                          widget.currentUser!.id)
                                        GestureDetector(
                                          onTap: () async {
                                            await chatsRef
                                                .doc(widget.chatID)
                                                .update({
                                              'memberIds':
                                                  FieldValue.arrayRemove(
                                                      [follower.id])
                                            }).then((value) {
                                              setState(() {
                                                _userFollowing.removeAt(index);
                                              });
                                              print('User Removed');
                                            });
                                          },
                                          child: Icon(Icons.delete,
                                              color: Colors.red, size: 23),
                                        ),
                                    ],
                                  ),
                                ),
                                // Spacer(),
                                // Spacer(),
                                // Align(
                                //     alignment: Alignment.centerRight,
                                //     child: Icon(Icons.delete, color: Colors.red))
                              ]),
                              SizedBox(height: 20)
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        await chatsRef.doc(widget.chatID).update({
                          'memberIds':
                              FieldValue.arrayRemove([widget.currentUser?.id])
                        }).then((value) {
                          Navigator.pop(context, 'isRemoved');
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => HomeScreen(
                          //         currentUserId: widget.currentUser?.id,
                          //        initialPage: 1),
                          //   ),
                          // );
                          setState(() {
                            _userFollowing.remove(widget.currentUser?.id);
                          });
                          print('User Removed');
                        });
                      },
                      child: Center(
                          child: Text('Leave Group',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 18))),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),

              // FutureBuilder(
              //   future: _users,
              //   builder: (context, snapshot) {
              //     if (!snapshot.hasData) {
              //       return Center(
              //         child: CircularProgressIndicator(),
              //       );
              //     }
              //     if (snapshot.data.docs.length == 0) {
              //       return Center(
              //         child: Text('No Users found! Please try again.',
              //             style: TextStyle(color: Colors.white)),
              //       );
              //     }
              //     return Container(
              //       height: 500,
              //       child: ListView.builder(
              //           itemCount: snapshot.data.docs.length,
              //           itemBuilder: (BuildContext context, int index) {
              //             AppUser user = AppUser.fromDoc(snapshot.data.docs[index]);
              //             // Prevent current user to send messages to himself
              //             print(user.profileImageUrl);
              //             return (widget.searchFrom != SearchFrom.homeScreen &&
              //                     user.id == _currentUserId)
              //                 ? SizedBox.shrink()
              //                 : _buildUserTile(user);
              //           }),
              //     );
              //   },
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
