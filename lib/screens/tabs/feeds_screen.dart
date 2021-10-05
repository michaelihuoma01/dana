import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/auth/login.dart';
import 'package:Dana/screens/pages/add_post.dart';
import 'package:Dana/screens/pages/notifications_screen.dart';
import 'package:Dana/screens/pages/story_screen.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/utils/shared_preferences_utils.dart';

import 'package:Dana/widgets/common_widgets/post_view.dart';
import 'package:Dana/widgets/common_widgets/video_post_view.dart';
import 'package:Dana/widgets/confirm_delete_dialog.dart';
import 'package:Dana/widgets/post_tile.dart';
import 'package:Dana/widgets/qrcode.dart';
import 'package:Dana/widgets/stories_widget.dart';
import 'package:Dana/widgets/text_post_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class FeedsScreen extends StatefulWidget {
  AppUser? currentUser;
  final Function? goToCameraScreen;
  ScrollController? homeController;

  FeedsScreen({this.currentUser, this.goToCameraScreen, this.homeController});

  @override
  _FeedsScreenState createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  List<Post> _posts = [];
  bool _isLoadingFeed = false;
  bool _isLoadingStories = false;
  List<AppUser> _followingUsersWithStories = [];
  CameraConsumer _cameraConsumer = CameraConsumer.post;
  StreamSubscription? stream;
  bool unreadNotifications = false;

  void _goToCameraScreen() {
    setState(() => _cameraConsumer = CameraConsumer.story);
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _setupFeed();
  }

  @override
  void dispose() {
    stream!.cancel();
    super.dispose();
  }

  _setupFeed() async {
    _setupStories();

    String? userId = await SharedPreferencesUtil.getUserId();

    print(userId);
    setState(() => _isLoadingFeed = true);

    // List<Post> posts = await DatabaseService.getFeedPosts(
    //   widget.currentUser.id,
    // );

    List<Post> posts = await DatabaseService.getAllFeedPosts(context);
    posts.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

    setState(() {
      _posts = posts;
      _isLoadingFeed = false;
    });

    stream = usersRef
        .doc(widget.currentUser!.id)
        // .where('memberIds', arrayContains: widget.currentUser.id)
        // .orderBy('recentTimestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      AppUser user = AppUser.fromDoc(snapshot);
      if (user.isVerified == true) {
        setState(() {
          unreadNotifications = true;
        });
      }
    });
  }

  void _setupStories() async {
    setState(() => _isLoadingStories = true);

    // Get currentUser followingUsers
    List<AppUser> followingUsers =
        await DatabaseService.getUserFollowingUsers(widget.currentUser?.id);

    print(widget.currentUser!.id);

    // AppUser currentUser =
    //     Provider.of<UserData>(context, listen: false).currentUser;

    List<Story>? currentUserStories =
        await StoriesService.getStoriesByUserId(widget.currentUser?.id, true);

    // Add current user to the first story circle
    // followingUsers.insert(0, widget.currentUser);

    // followingUsers.add(widget.currentUser);

    if (currentUserStories != null) {}

    /* A method to add Admin stories to each user */
    // if (widget.currentUser?.id != 'kAdminUId') {
    //   bool isFollowingAdmin = false;

    //   for (AppUser user in followingUsers) {
    //     if (user != null) {
    //       if (user.id == 'kAdminUId') {
    //         isFollowingAdmin = true;
    //       }
    //     }
    //   }
    //   // if current user doesn't follow admin
    //   if (!isFollowingAdmin) {
    //     // get admin stories
    //     List<Story> adminStories =
    //         await StoriesService.getStoriesByUserId('kAdminUId', true);
    //     if (!mounted) return;
    //     // if there is admin stories
    //     if (adminStories != null && adminStories.isNotEmpty) {
    //       // get admin user
    //       AppUser adminUser = await DatabaseService.getUserWithId('kAdminUId');
    //       if (!mounted) return;
    //       // add admin to story circle list
    //       followingUsers.insert(0, adminUser);
    //     }
    //   }
    // }
    /* End of method to add Admin stories to each user */

    if (mounted) {
      setState(() {
        _isLoadingStories = false;
        _followingUsersWithStories = followingUsers;
      });
    }
  }

  void _getCurrentUser() async {
    print('i have the current user now  ');

    // String userId = await SharedPreferencesUtil.getUserId();

    if (widget.currentUser!.name == null) {
      AuthService.logout(context);
    }
    // print('i have the current user now $userId ');
    // setState(() => _currentUser = currentUser);
    // AuthService.updateTokenWithUser(currentUser);
  }

  @override
  Widget build(BuildContext context) {
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
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          QrDialog(userID: widget.currentUser?.id));
                },
                child: Row(
                  children: [
                    Container(
                      height: 35,
                      width: 35,
                      child: CircleAvatar(
                        radius: 25.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(
                            (widget.currentUser!.profileImageUrl! == '')
                                ? placeHolderImageRef
                                : widget.currentUser!.profileImageUrl!),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PIN: ${widget.currentUser?.pin}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins-Regular',
                                fontWeight: FontWeight.bold)),
                        Text('${widget.currentUser?.name}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins-Regular')),
                      ],
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
              centerTitle: false,
              elevation: 0,
              brightness: Brightness.dark,
              actions: [
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddPost(
                                  currentUserId: widget.currentUser!.id)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Icon(Icons.post_add, color: lightColor, size: 28),
                    )),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      unreadNotifications = false;
                    });

                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsScreen(
                                currentUser: widget.currentUser)));

                    if (result == 'readNotifications') {
                      usersRef
                          .doc(widget.currentUser?.id)
                          .update({'isVerified': false});
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 13),
                    child: Stack(
                      children: [
                        Icon(FontAwesomeIcons.bell,
                            color: lightColor, size: 24),
                        if (unreadNotifications == true)
                          Positioned(
                              left: 12,
                              top: 4,
                              child: Icon(Icons.circle,
                                  color: darkColor, size: 11)),
                        if (unreadNotifications == true)
                          Positioned(
                              left: 15,
                              top: 6,
                              child: Icon(Icons.circle,
                                  color: Colors.red, size: 7)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20)
              ],
            )),
        body: !_isLoadingFeed
            ? RefreshIndicator(
                // If posts finished loading
                onRefresh: () => _setupFeed(),
                child: SingleChildScrollView(
                  controller: widget.homeController,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isLoadingStories
                            ? Container(
                                height: 88,
                                child: Center(
                                  child: SpinKitWanderingCubes(
                                      color: Colors.white, size: 40),
                                ),
                              )
                            : StoriesWidget(
                                _followingUsersWithStories, _goToCameraScreen),
                        // SizedBox(height: 30),
                        // BrandDivider(),
                        // SizedBox(height: 30),
                        // TextPost(),
                        // PostTile(),
                        SizedBox(height: 15),

                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _posts.length > 0 ? _posts.length : 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (_posts.length == 0) {
                              //If there is no posts
                              return Container(
                                height: MediaQuery.of(context).size.height,
                                child: Center(
                                  child: Text(S.of(context)!.nopost,
                                      style: TextStyle(color: Colors.white)),
                                ),
                              );
                            }

                            Post post = _posts[index];

                            return FutureBuilder(
                              future:
                                  DatabaseService.getUserWithId(post.authorId),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) {
                                  return SizedBox.shrink();
                                }

                                AppUser? author = snapshot.data;
                                return (post.imageUrl != null)
                                    ? PostView(
                                        postStatus: PostStatus.feedPost,
                                        currentUserId: widget.currentUser!.id,
                                        author: author,
                                        post: post,
                                      )
                                    : (post.videoUrl != null)
                                        ? VideoPostView(
                                            postStatus: PostStatus.feedPost,
                                            currentUserId:
                                                widget.currentUser!.id,
                                            author: author,
                                            post: post,
                                          )
                                        : TextPost(
                                            postStatus: PostStatus.feedPost,
                                            currentUserId:
                                                widget.currentUser!.id,
                                            author: author,
                                            post: post,
                                          );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                // If posts is loading
                child: SpinKitWanderingCubes(color: Colors.white, size: 40),
              ),
      ),
    ]);
  }
}
