import 'dart:io';

import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/calls/call_utilities.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/models/post_model.dart';
import 'package:Dana/models/story_model.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/pages/direct_messages/nested_screens/chat_screen.dart';
import 'package:Dana/screens/pages/direct_messages/nested_screens/full_screen_image.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/utils/utility.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:Dana/widgets/common_widgets/post_view.dart';
import 'package:Dana/widgets/common_widgets/video_post_view.dart';
import 'package:Dana/widgets/qrcode.dart';
import 'package:Dana/widgets/text_post_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  final String? userId;
  final String? currentUserId;
  final Function? onProfileEdited;
  final File? imageFile;
  final AppUser? appUser;

  UserProfile(
      {this.userId,
      this.currentUserId,
      this.appUser,
      this.onProfileEdited,
      this.imageFile});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;
  List<Post> _posts = [];
  int _displayPosts = 0; // 0 - grid, 1 - column
  AppUser? _profileUser;
 AppUser? _currentUser;
  List<Story>? _userStories;
  var _future;
  bool isFollower = false;
  bool isFollowingUser = false;
  bool isFriends = false;
  bool isRequest = false;
  bool notFriends = false;
  bool pendingFriends = false;
  List<AppUser> _friends = [];
  List<AppUser> _requests = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _setupUserStories();
    _setupIsFollowing();
    _setupFollowers();
    _setupFollowing();
    _setupPosts();
    _setupProfileUser();
    _setupFriends();
    _future = usersRef.doc(widget.userId).get();
  }

  _setupIsFollowing() async {
    bool isFollowingUser = await DatabaseService.isFollowingUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    if (!mounted) return;
    setState(() {
      _isFollowing = isFollowingUser;
    });
  }

  _setupFollowers() async {
    int userFollowersCount = await DatabaseService.numFollowers(widget.userId);
    if (!mounted) return;
    setState(() {
      _followersCount = userFollowersCount;
    });
  }

  _setupFollowing() async {
    int userFollowingCount = await DatabaseService.numFollowing(widget.userId);
    if (!mounted) return;
    setState(() {
      _followingCount = userFollowingCount;
    });
  }

  _setupPosts() async {
    List<Post> posts = await DatabaseService.getUserPosts(widget.userId);
    if (!mounted) return;
    setState(() {
      _posts = posts;
    });
  }

  _setupProfileUser() async {
    AppUser profileUser = await DatabaseService.getUserWithId(widget.userId);
   _currentUser =
        await DatabaseService.getUserWithId(widget.currentUserId);
    if (!mounted) return;
    setState(() {
      _profileUser = profileUser;
      // _currentUser = currentUser;
    });
    if (profileUser.id ==
        Provider.of<UserData>(context, listen: false).currentUser!.id) {
      AuthService.updateTokenWithUser(profileUser);
      Provider.of<UserData>(context, listen: false).currentUser = profileUser;
    }
  }

  _setupUserStories() async {
    List<Story>? userStories =
        await StoriesService.getStoriesByUserId(widget.userId, true);
    if (!mounted) return;

    if (userStories != null) {
      setState(() {
        _userStories = userStories;
      });
    }
  }

  _followOrUnfollow() {
    if (notFriends) {
      _followUser();
      print('notFriends');

      setState(() {
        isRequest = true;
        isFriends = false;
        pendingFriends = false;
        notFriends = false;
      });
    } else if (isRequest) {
      _followUser();
      print('request');

      setState(() {
        isRequest = false;
        isFriends = true;
        pendingFriends = false;
        notFriends = false;
      });
    } else if (pendingFriends) {
      _unfollowUser();
      print('pendingFriends');

      setState(() {
        isRequest = false;
        isFriends = false;
        pendingFriends = false;
        notFriends = true;
      });
    } else if (isFriends) {
      _unfollowUser();
      print('isFriends');
      setState(() {
        isRequest = false;
        isFriends = false;
        pendingFriends = false;
        notFriends = true;
      });
    }
    // _unfollowUser();
    setState(() {});
  }

  _unfollowUser() {
    DatabaseService.unfollowUser(
        currentUserId: widget.currentUserId, userId: widget.userId);
    if (!mounted) return;
  }

  void _followUser() {
    DatabaseService.followUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
      receiverToken: _profileUser!.token,
    );
    if (!mounted) return;
  }

  _setupFriends() async {
    isFollower = await DatabaseService.isUserFollower(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );

    isFollowingUser = await DatabaseService.isFollowingUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );

    if (isFollower == true && isFollowingUser == true) {
      setState(() {
        isFriends = true;
        isRequest = false;
        pendingFriends = false;
        notFriends = false;
      });
      print('isFriends');
    } else if (isFollower == true && isFollowingUser != true) {
      setState(() {
        isRequest = true;
        isFriends = false;
        pendingFriends = false;
        notFriends = false;
      });
      print('isRequest');
    } else if (isFollower != true && isFollowingUser != true) {
      setState(() {
        notFriends = true;
        isRequest = false;
        isFriends = false;
        pendingFriends = false;
      });
      print('notFriends');
    } else if (isFollower != true && isFollowingUser != true) {
      setState(() {
        pendingFriends = true;
        isRequest = false;
        isFriends = false;
        notFriends = false;
      });
      print('pendingFriends');
    }
  }

  GridTile _buildTilePost(Post post) {
    return GridTile(
        child: GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<bool>(
          builder: (BuildContext context) {
            return Center(
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
                  Scaffold(
                      backgroundColor: Colors.transparent,
                      appBar: AppBar(
                        iconTheme: IconThemeData(color: Colors.white),
                        backgroundColor: darkColor,
                        brightness: Brightness.dark,
                        title: Text(
                          'Posts',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ListView(
                          children: <Widget>[
                            Container(
                              child: PostView(
                                postStatus: PostStatus.feedPost,
                                currentUserId: widget.userId,
                                post: post,
                                author: _profileUser,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            );
          },
        ),
      ),
      child: Image(
        image: newMethod(post),
        fit: BoxFit.cover,
      ),
    ));
  }

  newMethod(Post post) => CachedNetworkImageProvider(post.imageUrl.toString());

  Widget _buildDisplayPosts() {
    if (_displayPosts == 0) {
      // Grid
      List<GridTile> tiles = [];

      _posts.forEach((post) => tiles.add(_buildTilePost(post)));
      return (tiles.length == 0)
          ? Center(
              child: Text('No Posts', style: TextStyle(color: Colors.white)))
          : GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: tiles,
            );
    } else {
      // Column
      List<PostView> postViews = [];
      _posts.forEach((post) {
        postViews.add(PostView(
          postStatus: PostStatus.feedPost,
          currentUserId: widget.userId,
          post: post,
          author: _profileUser,
        ));
      });
      return Column(
        children: postViews,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _setupFriends();
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
      FutureBuilder(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            AppUser user = AppUser.fromDoc(snapshot.data);
            return PickupLayout(
                 currentUser: _currentUser,

              scaffold: Scaffold(
                  appBar: PreferredSize(
                    child: AppBar(
                      automaticallyImplyLeading: true,
                      backgroundColor: darkColor,
                      brightness: Brightness.dark,
                      centerTitle: true,
                      elevation: 5,
                      actions: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    QrDialog(userID: user.id));
                          },
                            child: Icon(Icons.qr_code,
                                color: Colors.white, size: 20),
                          ),
                        )
                      ],
                      // actions: [
                      //   Padding(
                      //     padding: const EdgeInsets.symmetric(horizontal: 15),
                      //     child: Icon(Icons.qr_code, color: Colors.white),
                      //   ),
                      // ],
                      title: Text(user.name!,
                          style: TextStyle(color: Colors.white, fontSize: 22)),
                      iconTheme: IconThemeData(color: Colors.white),
                    ),
                    preferredSize: const Size.fromHeight(50),
                  ),
                  backgroundColor: Colors.transparent,
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FullScreenImage(user.profileImageUrl),
                                ));
                          },
                          child: Container(
                            height: 300,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              fit: BoxFit.fitWidth,
                              imageUrl: user.profileImageUrl!,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) {
                                return Center(
                                  child: CircularProgressIndicator(
                                      color: lightColor,
                                      value: downloadProgress.progress),
                                );
                              },
                              errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  child: Image.asset(placeHolderImageRef)),
                            ),
                          ),
                        ),
                        Container(
                          color: darkColor,
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        GestureDetector(
                                          onTap: () {
                                            Clipboard.setData(
                                                ClipboardData(text: user.pin));
                                            Utility.showMessage(context,
                                                message: 'Pin Copied!',
                                                pulsate: false,
                                                bgColor: Colors.green[600]!);
                                          },
                                          child: Text('PIN: ${user.pin}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18)),
                                        ),
                                        SizedBox(width: 15),
                                        if (!user.isPublic! && isFriends)
                                          GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            ChatScreen(
                                                                receiverUser:
                                                                    _profileUser,
                                                                isGroup: false,
                                                                imageFile: widget
                                                                    .imageFile)));
                                                print(_profileUser!.id);
                                              },
                                              child: Icon(Icons.chat_bubble,
                                                  color: Colors.white, size: 17)),
                                        SizedBox(width: 15),
                                        if (!user.isPublic! && isFriends)
                                          GestureDetector(
                                              onTap: () {
                                                try {
                                                  CallUtils.dial(
                                                      from: _currentUser!,
                                                      to: _profileUser!,
                                                      context: context,
                                                      isAudio: false);
                                                } catch (e) {
                                                  print('=============$e');
                                                }
                                              },
                                              child: Icon(FontAwesomeIcons.video,
                                                  color: Colors.white, size: 15)),
                                        SizedBox(width: 15),
                                        if (!user.isPublic! && isFriends)
                                          GestureDetector(
                                              onTap: () {
                                                try {
                                                  CallUtils.dial(
                                                      from: _currentUser!,
                                                      to: _profileUser!,
                                                      context: context,
                                                      isAudio: true);
                                                } catch (e) {
                                                  print('=============$e');
                                                }
                                              },
                                              child: Icon(
                                                  FontAwesomeIcons.phoneAlt,
                                                  color: Colors.white,
                                                  size: 15)),
                                      ]),
                                      OutlinedButton(
                                          style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          new BorderRadius
                                                              .circular(10))),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      (isFriends == true)
                                                          ? Colors.red
                                                          : (isRequest == true)
                                                              ? Colors.green
                                                              : (pendingFriends ==
                                                                      true)
                                                                  ? Colors.grey
                                                                  : lightColor)),
                                          onPressed: _followOrUnfollow,
                                          child: Text(
                                              (isFriends == true)
                                                  ?  S.of(context)!.remove
                                                  : (isRequest == true)
                                                      ?  S.of(context)!.accept
                                                      : (pendingFriends == true)
                                                          ? 'Sent'
                                                          :  S.of(context)!.add,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      'Poppins-Regular'))),
                                    ],
                                  )),
                              BrandDivider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text( S.of(context)!.bio,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(user.bio!,
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14)),
                              ),
                              BrandDivider(),
                            ],
                          ),
                        ),
                        (!user.isPublic! && isFriends)
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _posts.length > 0 ? _posts.length : 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (_posts.length == 0) {
                                    //If there is no posts
                                    return Center(
                                        child: Text( S.of(context)!.nopost,
                                            style:
                                                TextStyle(color: Colors.white)));
                                  }
            
                                  Post post = _posts[index];
            
                                  return FutureBuilder(
                                    future: DatabaseService.getUserWithId(
                                        post.authorId),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      if (!snapshot.hasData) {
                                        return SizedBox.shrink();
                                      }
            
                                      AppUser? author = snapshot.data;
            
                                      return (post.imageUrl == null)
                                          ? TextPost(
                                              postStatus: PostStatus.feedPost,
                                              currentUserId: widget.currentUserId,
                                              author: author,
                                              post: post,
                                            )
                                          : (post.videoUrl != null)
                                              ? VideoPostView(
                                                  postStatus: PostStatus.feedPost,
                                                  currentUserId:
                                                      widget.currentUserId,
                                                  author: author,
                                                  post: post,
                                                )
                                              : PostView(
                                                  postStatus: PostStatus.feedPost,
                                                  currentUserId:
                                                      widget.currentUserId,
                                                  author: author,
                                                  post: post,
                                                );
                                    },
                                  );
                                })
                            : Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 40),
                                    Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border:
                                                Border.all(color: Colors.white)),
                                        padding: const EdgeInsets.all(15),
                                        child: Icon(Icons.lock,
                                            color: Colors.white, size: 26)),
                                    SizedBox(height: 5),
                                    Text('This Account is Private',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                      ],
                    ),
                  )),
            );
          })
    ]);
  }
}
