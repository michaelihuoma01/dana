import 'dart:io';

import 'package:Dana/screens/pages/qr_code_scanner.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/user_data.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/pages/direct_messages/nested_screens/chat_screen.dart';
import 'package:Dana/screens/pages/friend_request.dart';
import 'package:Dana/screens/pages/user_profile.dart';
import 'package:Dana/services/api/database_service.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/custom_navigation.dart';
import 'package:Dana/utilities/themes.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/add_story.dart';
import 'package:Dana/widgets/contact_tile.dart';
import 'package:Dana/widgets/custom_modal_progress_hud.dart';
import 'package:Dana/widgets/search_tile.dart';
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

  List<AppUser> _friends = [];
  List<AppUser> _requests = [];

  bool _isLoading = false;
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
    _setupFriends();
  }

  _setupFriends() async {
    List<String?> followingUsers =
        await DatabaseService.getUserFollowingIds(widget.currentUser?.id);

    List<String?> followerUsers =
        await DatabaseService.getUserFollowersIds(widget.currentUser?.id);

    var friendList = [...followingUsers, ...followerUsers].toSet().toList();

    for (String? userId in friendList) {
      // var isFollowing = await DatabaseService.isFollowingUser(
      //   currentUserId: widget.currentUser!.id,
      //   userId: userId,
      // );

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
        setState(() {
          isFriends = true;
          _friends.add(friends);
        });
      } else if (isFollowing == false && isFollower == true) {
        setState(() {
          isRequest = true;
          _requests.add(friends);
        });
      } 
    } 
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
              title: Text(S.of(context)!.friends,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'Poppins-Regular',
                      fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              centerTitle: false,
              automaticallyImplyLeading: false,
              elevation: 0,
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                QrCodeScanner(widget.currentUser!.id)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.qr_code_scanner_rounded,
                        color: Colors.white),
                  ),
                )
              ],
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
                          hintText: S.of(context)!.searchby,
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
                                      Text(
                                          '${_requests.length} ${S.of(context)!.request}',
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
                                        child: Text(S.of(context)!.norequest,
                                            style:
                                                TextStyle(color: Colors.grey))),
                                SizedBox(height: 20),
                                Text(
                                    '${_friends.length.toString()} ${(_friends.length == 1) ? S.of(context)!.friends : S.of(context)!.friends} ',
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
