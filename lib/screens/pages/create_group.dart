import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/generated/l10n.dart';
import 'package:dana/models/models.dart';
import 'package:dana/services/services.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utilities/themes.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/contact_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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

  final TextEditingController textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

  Widget _buildUserTile(AppUser user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 20.0,
        backgroundImage: (user.profileImageUrl!.isEmpty
                ? AssetImage(placeHolderImageRef)
                : CachedNetworkImageProvider(user.profileImageUrl!))
            as ImageProvider<Object>?,
      ),
      title: Text(user.name!,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
      subtitle:
          Text(user.pin!, style: TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: widget.searchFrom == SearchFrom.createStoryScreen
          ? FlatButton(
              child: Text(
                'Send',
                style: kFontSize18TextStyle.copyWith(color: Colors.white),
              ),
              color: Colors.blue,
              onPressed: () => {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => ChatScreen(
                //       receiverUser: user,
                //       imageFile: widget.imageFile,
                //     ),
                //   ),
                // ),
              },
            )
          : SizedBox.shrink(),
      // onTap: widget.searchFrom == SearchFrom.homeScreen
      //     ? () => Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (_) => UserProfile(
      //               // goToCameraScreen: () =>
      //               //     CustomNavigation.navigateToHomeScreen(
      //               //         context,
      //               //         Provider.of<UserData>(context, listen: false)
      //               //             .currentUserId,
      //               //         initialPage: 0),
      //               // isCameFromBottomNavigation: false,
      //               userId: user.id,
      //               currentUserId: Provider.of<UserData>(context, listen: false)
      //                   .currentUserId,
      //             ),
      //           ),
      //         )
      //     : widget.searchFrom == SearchFrom.messagesScreen
      //         ? () => Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (_) => ChatScreen(
      //                   receiverUser: user,
      //                   imageFile: widget.imageFile,
      //                 ),
      //               ),
      //             )
      //         : null,
    );
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
        Scaffold(
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
                        color: Colors.white, fontFamily: 'Poppins-Regular')),
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
            onPressed: () {
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
                          borderSide: BorderSide(color: lightColor, width: 1)),
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
                        return GestureDetector(
                            // onTap: () => Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (_) => UserProfile(
                            //         // goToCameraScreen: () =>
                            //         //     CustomNavigation.navigateToHomeScreen(
                            //         //         context,
                            //         //         Provider.of<UserData>(context, listen: false)
                            //         //             .currentUserId,
                            //         //         initialPage: 0),
                            //         // isCameFromBottomNavigation: false,
                            //         userId: follower.id,
                            //         currentUserId:
                            //             Provider.of<UserData>(
                            //                     context,
                            //                     listen: false)
                            //                 .currentUserId,
                            //       ),
                            //     )),
                            child: Theme(
                          data: ThemeData(unselectedWidgetColor: lightColor),
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
                                  backgroundImage:
                                      (follower.profileImageUrl!.isEmpty
                                              ? AssetImage(placeHolderImageRef)
                                              : CachedNetworkImageProvider(
                                                  follower.profileImageUrl!))
                                          as ImageProvider<Object>?,
                                ),
                              ),
                              SizedBox(width: 15),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(follower.name!,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                    Text('${S.of(context)!.pin}: ${follower.pin}',
                                        maxLines: 3,
                                        style: TextStyle(color: Colors.grey)),
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
                        )

                            //

                            );
                      },
                    ),
                  ),
                ),
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
      ],
    );
  }
}
