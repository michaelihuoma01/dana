import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class BroadcastMessage extends StatefulWidget {
  final SearchFrom searchFrom;
  final File imageFile;
  AppUser currentUser;

  BroadcastMessage(
      {@required this.searchFrom, this.currentUser, this.imageFile});

  @override
  _BroadcastMessageState createState() => _BroadcastMessageState();
}

class _BroadcastMessageState extends State<BroadcastMessage> {
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot> _users;
  String _searchText = '';
  List<AppUser> _userFollowing = [];
  List<AppUser> _selectedUsers = List();

  List<bool> _userFollowingState = [];
  int _followingCount = 0;
  bool _isLoading = false;
  bool _selectAll = false;

  final TextEditingController textEditingController = TextEditingController();

  sendBroadcastMessage() async {
    // _selectedUsers.add(widget.currentUser);

    Timestamp timestamp = Timestamp.now();
    Map<String, dynamic> readStatus = {};

    readStatus[widget.currentUser.id] = false;

    for (AppUser user in _selectedUsers) {
      readStatus[user.id] = false;
    }

    String groupName = textEditingController.text;

    _selectedUsers.forEach((element) async {
      print('sent to ${element.name}');

      Chat chat =
          await ChatService.getChatByUsers([widget.currentUser.id, element.id]);

      bool isChatExist = chat != null;
      DocumentReference res;

      if (isChatExist == false) {
        res = await chatsRef.add({
          'groupName': '',
          'admin': '',
          'memberIds': [widget.currentUser.id, element.id],
          'recentMessage': groupName,
          'recentSender': widget.currentUser.id,
          'recentTimestamp': timestamp,
          'readStatus': readStatus
        });
      }

      Chat _chat = Chat(
        id: (isChatExist == false) ? res.id : chat.id,
        recentMessage: groupName,
        admin: '',
        groupName: '',
        recentSender: widget.currentUser.id,
        recentTimestamp: timestamp,
        memberIds: [widget.currentUser.id, element.id],
        readStatus: readStatus,
      );

      Message message = Message(
        senderId: widget.currentUser.id,
        text: groupName,
        imageUrl: null,
        fileName: null,
        giphyUrl: null,
        audioUrl: null,
        videoUrl: null,
        fileUrl: null,
        timestamp: Timestamp.now(),
        isLiked: false,
      );

      ChatService.sendChatMessage(_chat, message, element);
      chatsRef.doc(_chat.id).update({
        'readStatus.${element.id}': false,
        'readStatus.${widget.currentUser.id}': true
      });
    });
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
        await DatabaseService.numFollowing(widget.currentUser.id);
    if (!mounted) return;
    setState(() {
      _followingCount = userFollowingCount;
    });

    List<String> userFollowingIds =
        await DatabaseService.getUserFollowingIds(widget.currentUser.id);

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
        backgroundImage: user.profileImageUrl.isEmpty
            ? AssetImage(placeHolderImageRef)
            : CachedNetworkImageProvider(user.profileImageUrl),
      ),
      title: Text(user.name,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
      subtitle:
          Text(user.pin, style: TextStyle(color: Colors.grey, fontSize: 12)),
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
    String _currentUserId = Provider.of<UserData>(context).currentUser.id;
    void _clearSearch() {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _searchController.clear());
      setState(() {
        _users = null;
        _searchText = '';
      });
    }

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
                title: Text('Broadcast Message',
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
            child: const Icon(Icons.send_rounded, size: 19),
            mini: true,
            onPressed: () {
              if (textEditingController.value != null) {
                sendBroadcastMessage();
                Navigator.pop(context);
              }
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
                    maxLines: 5,
                    controller: textEditingController,
                    decoration: InputDecoration(
                        hintText: 'Enter Message',
                        hintStyle: TextStyle(color: Colors.grey),
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
                                BorderSide(color: lightColor, width: 1))),
                    style: TextStyle(color: Colors.white),
                    cursorColor: lightColor,
                  ),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    _userFollowing.forEach((element) {
                      setState(() {
                        _selectedUsers.add(element);
                        _selectAll = true;
                      });
                    });
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child:
                        Text('Select All', style: TextStyle(color: lightColor)),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      itemCount: _userFollowing.length,
                      itemBuilder: (BuildContext context, int index) {
                        AppUser follower = _userFollowing[index];
                        AppUser filteritem = _selectedUsers.firstWhere(
                            (item) => item.id == follower.id,
                            orElse: () => null);
                        return Theme(
                            data: ThemeData(unselectedWidgetColor: lightColor),
                            child: CheckboxListTile(
                              value: (_selectAll == true) ? true : filteritem != null,
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
                                        follower.profileImageUrl.isEmpty
                                            ? AssetImage(placeHolderImageRef)
                                            : CachedNetworkImageProvider(
                                                follower.profileImageUrl),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(follower.name,
                                          style:
                                              TextStyle(color: Colors.white)),
                                      SizedBox(height: 3),
                                      Text('PIN: ${follower.pin}',
                                          maxLines: 3,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14)),
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
                                        (item) => item.id == follower.id);
                                  }
                                });
                              },
                            ));
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
