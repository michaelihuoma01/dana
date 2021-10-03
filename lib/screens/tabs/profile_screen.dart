import 'package:cached_network_image/cached_network_image.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/models/user_data.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/pages/direct_messages/nested_screens/full_screen_image.dart';
import 'package:Dana/screens/pages/edit_profile.dart';
import 'package:Dana/screens/pages/settings.dart';
import 'package:Dana/services/api/auth_service.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/utils/utility.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:Dana/widgets/appbar_widget.dart';
import 'package:Dana/widgets/common_widgets/post_view.dart';
import 'package:Dana/widgets/common_widgets/video_post_view.dart';
import 'package:Dana/widgets/qrcode.dart';
import 'package:Dana/widgets/text_post_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser? user;

  ProfileScreen({this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;
  List<Post> _posts = [];
  int _displayPosts = 0; // 0 - grid, 1 - column
  AppUser? _profileUser;
  List<Story>? _userStories;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupPosts();
    _setupProfileUser();
  }

  _setupPosts() async {
    List<Post> posts = await DatabaseService.getUserPosts(widget.user!.id);
    if (!mounted) return;
    setState(() {
      _posts = posts;
    });
  }

  _setupProfileUser() async {
    AppUser profileUser = await DatabaseService.getUserWithId(widget.user!.id);
    if (!mounted) return;
    setState(() => _profileUser = profileUser);
    if (profileUser.id ==
        Provider.of<UserData>(context, listen: false).currentUser!.id) {
      AuthService.updateTokenWithUser(profileUser);
      Provider.of<UserData>(context, listen: false).currentUser = profileUser;
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
                        automaticallyImplyLeading: false,
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
                                currentUserId: widget.user!.id,
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
        image: CachedNetworkImageProvider(post.imageUrl.toString()),
        fit: BoxFit.cover,
      ),
    ));
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
      FutureBuilder(
          future: usersRef.doc(widget.user!.id).get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: SpinKitWanderingCubes(color: Colors.white, size: 40),
              );
            }
            AppUser user = AppUser.fromDoc(snapshot.data);
            return Scaffold(
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
                        height: 250,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Text(user.name!,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  SizedBox(width: 10),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EditProfile(
                                                  userId: user.id,
                                                  user: user,
                                                  updateUser:
                                                      (AppUser updateUser) {
                                                    AppUser updatedUser =
                                                        AppUser(
                                                      id: updateUser.id,
                                                      name: updateUser.name,
                                                      email: updateUser.email,
                                                      profileImageUrl:
                                                          updateUser
                                                              .profileImageUrl,
                                                      bio: updateUser.bio,
                                                      isVerified:
                                                          updateUser.isVerified,
                                                      role: updateUser.role,
                                                    );

                                                    Provider.of<UserData>(
                                                                context,
                                                                listen: false)
                                                            .currentUser =
                                                        updatedUser;

                                                    AuthService
                                                        .updateTokenWithUser(
                                                            updatedUser);
                                                  })));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: lightColor,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      // width: 30.0,
                                      child: Icon(Icons.edit,
                                          color: Colors.white, size: 20),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingsScreen()));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: lightColor,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      // width: 30.0,
                                      child: Icon(Icons.settings,
                                          color: Colors.white, size: 20),
                                    ),
                                  ),
                                  // TextButton(
                                  //   style: ButtonStyle(
                                  //       shape: MaterialStateProperty.all(
                                  //           RoundedRectangleBorder(
                                  //               borderRadius:
                                  //                   new BorderRadius.circular(
                                  //                       10))),
                                  //       backgroundColor:
                                  //           MaterialStateProperty.all(
                                  //               lightColor)),

                                  //   child: Text('Edit',
                                  //       style: TextStyle(
                                  //           fontSize: 14,
                                  //           color: Colors.white,
                                  //           fontFamily: 'Poppins-Regular')),
                                  // ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(children: [
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
                                          color: Colors.white, fontSize: 16)),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            QrDialog(userID: widget.user?.id));
                                  },
                                  child: Icon(Icons.qr_code,
                                      color: Colors.white, size: 20),
                                )
                              ]),
                            ),
                            BrandDivider(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(S.of(context)!.bio,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _posts.length > 0 ? _posts.length : 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (_posts.length == 0) {
                            //If there is no posts
                            return Center(
                                child: Text('You don\'t have any post yet',
                                    style: TextStyle(color: Colors.white)));
                          }

                          Post post = _posts[index];

                          return FutureBuilder(
                            future:
                                DatabaseService.getUserWithId(post.authorId),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }

                              AppUser? author = snapshot.data;

                              if (post.imageUrl != null)
                                return PostView(
                                    postStatus: PostStatus.feedPost,
                                    currentUserId: widget.user!.id,
                                    author: author,
                                    post: post);

                              if (post.videoUrl != null)
                                return VideoPostView(
                                  postStatus: PostStatus.feedPost,
                                  currentUserId: widget.user!.id,
                                  author: author,
                                  post: post,
                                );
                              else
                                return TextPost(
                                  postStatus: PostStatus.feedPost,
                                  currentUserId: widget.user!.id,
                                  author: author,
                                  post: post,
                                );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                )));
          })
    ]);
  }
}
