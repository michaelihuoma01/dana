import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/models/user_data.dart';
import 'package:dana/models/user_model.dart';
import 'package:dana/screens/pages/direct_messages/nested_screens/chat_screen.dart';
import 'package:dana/screens/pages/friend_request.dart';
import 'package:dana/screens/pages/user_profile.dart';
import 'package:dana/services/api/database_service.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utilities/custom_navigation.dart';
import 'package:dana/utilities/themes.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/add_story.dart';
import 'package:dana/widgets/contact_tile.dart';
import 'package:dana/widgets/custom_modal_progress_hud.dart';
import 'package:dana/widgets/search_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContactScreen extends StatefulWidget {
  final SearchFrom searchFrom;
  final File? imageFile;
  AppUser? currentUser;
  bool? isReadIcon = false;

  ContactScreen(
      {required this.searchFrom,
      this.currentUser,
      this.isReadIcon,
      this.imageFile});

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot>? _users;
  String _searchText = '';

  List<AppUser> _userFollowers = [];
  List<AppUser> _userFollowing = [];
  List<AppUser> _friends = [];
  List<AppUser> _requests = [];
  List<AppUser> _friendRequests = [];

  bool _isLoading = false;
  List<bool> _userFollowersState = [];
  List<bool> _userFollowingState = [];
  int _followingCount = 0;
  int _followersCount = 0;
  bool isFollower = false;
  bool isFollowingUser = false;
  bool isFriends = false;
  bool isRequest = false;

  @override
  void initState() {
    super.initState();

    _setupAll();
  }

  _setupAll() async {
    setState(() {
      _isLoading = true;
    });
    await _setupFollowers();
    await _setupFollowing();
    _setupFriends();
  }

  Future _setupFollowers() async {
    int userFollowersCount =
        await DatabaseService.numFollowers(widget.currentUser!.id);
    if (!mounted) return;
    setState(() {
      _followersCount = userFollowersCount;
    });

    List<String> userFollowersIds =
        await DatabaseService.getUserFollowersIds(widget.currentUser!.id);
    List<AppUser> userFollowers = [];
    List<bool> userFollowersState = [];
    for (String userId in userFollowersIds) {
      AppUser user = await DatabaseService.getUserWithId(userId);
      userFollowersState.add(true);
      userFollowers.add(user);
    }

    setState(() {
      _userFollowersState = userFollowersState;
      _userFollowers = userFollowers;
      _followersCount = userFollowers.length;
      if (_followersCount != _followersCount) {
        setState(() => _followersCount = _followersCount);
      }
    });
  }

  Future _setupFollowing() async {
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
  }

  _setupFriends() async {
    QuerySnapshot usersSnapshot = await usersRef.get();

    for (var userDoc in usersSnapshot.docs) {
      AppUser user = AppUser.fromDoc(userDoc);

      isFollower = await DatabaseService.isUserFollower(
        currentUserId: widget.currentUser!.id,
        userId: user.id,
      );

      isFollowingUser = await DatabaseService.isFollowingUser(
        currentUserId: widget.currentUser!.id,
        userId: user.id,
      );

      if (widget.currentUser!.id == user.id) {
        print('skipping current user');
      } else {
        if (isFollower == true && isFollowingUser == true) {
          isFriends = true;
          _friends.add(user);

          print('friends ${user.name} $isFriends');
          setState(() {
            _isLoading = false;
          });
        } else if (isFollower == true && isFollowingUser != true) {
          isRequest = true;
          _requests.add(user);

          print('not friends ${user.name} $isFriends');
        } else {
          isRequest = false;
          isFriends = false;
        }
      }
    }
    print(_friends.length);
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
      subtitle: Text('PIN: ${user.pin}',
          style: TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: widget.searchFrom == SearchFrom.createStoryScreen
          ? FlatButton(
              child: Text(
                'Send',
                style: kFontSize18TextStyle.copyWith(color: Colors.white),
              ),
              color: Colors.blue,
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      receiverUser: user,
                      imageFile: widget.imageFile,
                    ),
                  ),
                ),
              },
            )
          : SizedBox.shrink(),
      onTap: widget.searchFrom == SearchFrom.homeScreen
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfile(
                      // goToCameraScreen: () =>
                      //     CustomNavigation.navigateToHomeScreen(
                      //         context,
                      //         Provider.of<UserData>(context, listen: false)
                      //             .currentUserId,
                      //         initialPage: 0),
                      // isCameFromBottomNavigation: false,
                      userId: user.id,
                      currentUserId: widget.currentUser!.id),
                ),
              )
          : widget.searchFrom == SearchFrom.messagesScreen
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        receiverUser: user,
                        imageFile: widget.imageFile,
                        isGroup: false,
                      ),
                    ),
                  )
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    String? _currentUserId = Provider.of<UserData>(context).currentUser!.id;
    void _clearSearch() {
      WidgetsBinding.instance!
          .addPostFrameCallback((_) => _searchController.clear());
      setState(() {
        _users = null;
        _searchText = '';
      });
    }

    return Stack(children: [
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
              title: Text('Friends',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontFamily: 'Poppins-Regular',
                      fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              centerTitle: false,
              automaticallyImplyLeading: false,
              elevation: 0,
              brightness: Brightness.dark,
            )),
        body: CustomModalProgressHUD(
          inAsyncCall: _isLoading,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          hintText: 'Search by pin',
                          suffixIcon: _searchText.trim().isEmpty
                              ? null
                              : GestureDetector(
                                  onTap: _clearSearch,
                                  child: Icon(Icons.clear, color: Colors.white),
                                ),
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.white)),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      onChanged: (value) {
                        if (value.trim().isNotEmpty) {
                          setState(() {
                            _searchText = value;
                            String? sentence = toBeginningOfSentenceCase(value);
                            _users = DatabaseService.searchUsers(sentence);
                          });
                        }
                      },
                      onSubmitted: (input) {
                        if (input.trim().isNotEmpty) {
                          setState(() {
                            _searchText = input;
                            String? sentence = toBeginningOfSentenceCase(input);
                            _users = DatabaseService.searchUsers(sentence);
                          });
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    _users == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${_requests.length} Requests',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Poppins-Regular')),
                                      // InkWell(
                                      //   onTap: () {
                                      //     Navigator.push(
                                      //         context,
                                      //         MaterialPageRoute(
                                      //             builder: (context) =>
                                      //                 FriendRequest()));
                                      //   },
                                      //   child: Text('Show all',
                                      //       style: TextStyle(
                                      //           color: lightColor,
                                      //           fontFamily: 'Poppins-Regular')),
                                      // ),
                                    ]),
                                SizedBox(height: 10),
                                (_requests.length != 0)
                                    ? Container(
                                        height: 80,
                                        child: ListView.builder(
                                          itemCount: _requests.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            AppUser following =
                                                _requests[index];
                                            String result = following.name!;
                                            if (result.contains(' ')) {
                                              result = following.name!
                                                  .substring(
                                                      0,
                                                      following.name!
                                                          .indexOf(' '));
                                            }

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: GestureDetector(
                                                onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => UserProfile(
                                                          userId: following.id,
                                                          currentUserId: widget
                                                              .currentUser!.id),
                                                    )),
                                                child: Column(
                                                  children: [
                                                    GestureDetector(
                                                      child: Container(
                                                        height: 50,
                                                        width: 50,
                                                        child: CircleAvatar(
                                                          radius: 25.0,
                                                          backgroundColor:
                                                              Colors.grey,
                                                          backgroundImage: (following
                                                                  .profileImageUrl!
                                                                  .isEmpty
                                                              ? AssetImage(
                                                                  placeHolderImageRef)
                                                              : CachedNetworkImageProvider(
                                                                  following
                                                                      .profileImageUrl!,
                                                                )) as ImageProvider<
                                                              Object>?,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(result,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                            'You have no friend request',
                                            style:
                                                TextStyle(color: Colors.grey))),
                                SizedBox(height: 20),
                                Text(
                                    '${_friends.length.toString()} ${(_friends.length == 1) ? 'Friend' : 'Friends'} ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Poppins-Regular')),
                                SizedBox(height: 20),
                                (_friends != null)
                                    ? Container(
                                        height: 500,
                                        child: ListView.builder(
                                          itemCount: _friends.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            AppUser follower = _friends[index];

                                            return InkWell(
                                                onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => UserProfile(
                                                          userId: follower.id,
                                                          currentUserId: widget
                                                              .currentUser!.id),
                                                    )),
                                                child: ContactTile(
                                                    appUser: follower));
                                          },
                                        ),
                                      )
                                    : Center(
                                        child: SpinKitWanderingCubes(
                                            color: Colors.white, size: 40)),
                              ])
                        : FutureBuilder(
                            future: _users,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SpinKitWanderingCubes(
                                      color: Colors.white, size: 40),
                                );
                              }
                              if ((snapshot.data! as QuerySnapshot)
                                      .docs
                                      .length ==
                                  0) {
                                return Center(
                                  child: Text(
                                      'No Users found! Please try again.',
                                      style: TextStyle(color: Colors.white)),
                                );
                              }
                              return Container(
                                height: 500,
                                child: ListView.builder(
                                    itemCount: (snapshot.data! as QuerySnapshot)
                                        .docs
                                        .length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      AppUser user = AppUser.fromDoc(
                                          (snapshot.data! as QuerySnapshot)
                                              .docs[index]);
                                      // Prevent current user to send messages to himself
                                      return (widget.searchFrom !=
                                                  SearchFrom.homeScreen &&
                                              user.id == _currentUserId)
                                          ? SizedBox.shrink()
                                          : _buildUserTile(user);
                                    }),
                              );
                            },
                          )
                  ]),
            ),
          ),
        ),
      )
    ]);
  }
}
