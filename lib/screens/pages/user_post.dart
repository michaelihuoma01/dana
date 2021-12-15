// import 'dart:io';

// import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
// import 'package:Dana/widgets/custom_modal_progress_hud.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:Dana/calls/call_utilities.dart';
// import 'package:Dana/generated/l10n.dart';
// import 'package:Dana/models/models.dart';
// import 'package:Dana/models/post_model.dart';
// import 'package:Dana/models/story_model.dart';
// import 'package:Dana/models/user_model.dart';
// import 'package:Dana/screens/pages/direct_messages/nested_screens/chat_screen.dart';
// import 'package:Dana/screens/pages/direct_messages/nested_screens/full_screen_image.dart';
// import 'package:Dana/services/services.dart';
// import 'package:Dana/utilities/constants.dart';
// import 'package:Dana/utils/constants.dart';
// import 'package:Dana/utils/utility.dart';
// import 'package:Dana/widgets/BrandDivider.dart';
// import 'package:Dana/widgets/common_widgets/post_view.dart';
// import 'package:Dana/widgets/common_widgets/video_post_view.dart';
// import 'package:Dana/widgets/qrcode.dart';
// import 'package:Dana/widgets/text_post_tile.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class UserPost extends StatefulWidget {
//   final String? userId;
//   final String? currentUserId;
//   final Function? onProfileEdited;
//   final File? imageFile;
//   final AppUser? appUser;

//   UserPost(
//       {this.userId,
//       this.currentUserId,
//       this.appUser,
//       this.onProfileEdited,
//       this.imageFile});

//   @override
//   _UserPostState createState() => _UserPostState();
// }

// class _UserPostState extends State<UserPost> {
//   List<Post> _posts = [];
//   int _displayPosts = 0; // 0 - grid, 1 - column
//   AppUser? _profileUser;
//   AppUser? _currentUser;
//   bool _isLoading = false;
//   var _future;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _setupAll();
//     _future = usersRef.doc(widget.userId).get();
//   }

//   _setupAll() {
//     _setupPosts();
//   }

//   _setupPosts() async {
//     List<Post> posts = await DatabaseService.getUserPosts(widget.userId);
//     if (!mounted) return;
//     setState(() {
//       _posts = posts;
//     });
//   }

//   GridTile _buildTilePost(Post post) {
//     return GridTile(
//         child: GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute<bool>(
//           builder: (BuildContext context) {
//             return Center(
//               child: Stack(
//                 children: [
//                   Container(
//                     height: double.infinity,
//                     color: darkColor,
//                     child: Image.asset(
//                       'assets/images/background.png',
//                       width: double.infinity,
//                       height: 300,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Scaffold(
//                       backgroundColor: Colors.transparent,
//                       appBar: AppBar(
//                         iconTheme: IconThemeData(color: Colors.white),
//                         backgroundColor: darkColor,
//                         brightness: Brightness.dark,
//                         title: Text(
//                           'Posts',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       body: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 20),
//                         child: ListView(
//                           children: <Widget>[
//                             Container(
//                               child: PostView(
//                                 postStatus: PostStatus.feedPost,
//                                 currentUserId: widget.userId,
//                                 post: post,
//                                 author: _profileUser,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//       child: Image(
//         image: newMethod(post),
//         fit: BoxFit.cover,
//       ),
//     ));
//   }

//   newMethod(Post post) => CachedNetworkImageProvider(post.imageUrl.toString());

//   Widget _buildDisplayPosts() {
//     if (_displayPosts == 0) {
//       // Grid
//       List<GridTile> tiles = [];

//       _posts.forEach((post) => tiles.add(_buildTilePost(post)));
//       return (tiles.length == 0)
//           ? Center(
//               child: Text('No Posts', style: TextStyle(color: Colors.white)))
//           : GridView.count(
//               crossAxisCount: 3,
//               childAspectRatio: 1.0,
//               mainAxisSpacing: 2.0,
//               crossAxisSpacing: 2.0,
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               children: tiles,
//             );
//     } else {
//       // Column
//       List<PostView> postViews = [];
//       _posts.forEach((post) {
//         postViews.add(PostView(
//           postStatus: PostStatus.feedPost,
//           currentUserId: widget.userId,
//           post: post,
//           author: _profileUser,
//         ));
//       });
//       return Column(
//         children: postViews,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(children: [
//       Container(
//         height: double.infinity,
//         color: darkColor,
//         child: Image.asset(
//           'assets/images/background.png',
//           width: double.infinity,
//           height: 300,
//           fit: BoxFit.cover,
//         ),
//       ),
//       FutureBuilder(
//           future: _future,
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (!snapshot.hasData) {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//             AppUser user = AppUser.fromDoc(snapshot.data);
//             return PickupLayout(
//               currentUser: _currentUser,
//               scaffold: Scaffold(
//                 appBar: PreferredSize(
//                   child: AppBar(
//                     automaticallyImplyLeading: true,
//                     backgroundColor: darkColor,
//                     brightness: Brightness.dark,
//                     centerTitle: true,
//                     elevation: 5,
//                     title: Text(user.name!,
//                         style: TextStyle(color: Colors.white, fontSize: 22)),
//                     iconTheme: IconThemeData(color: Colors.white),
//                   ),
//                   preferredSize: const Size.fromHeight(50),
//                 ),
//                 backgroundColor: Colors.transparent,
//                 body: ListView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: _posts.length > 0 ? _posts.length : 1,
//                     itemBuilder: (BuildContext context, int index) {
//                       if (_posts.length == 0) {
//                         //If there is no posts
//                         return Center(
//                             child: Text(S.of(context)!.nopost,
//                                 style: TextStyle(color: Colors.white)));
//                       }

//                       Post post = _posts[index];

//                       return FutureBuilder(
//                         future: DatabaseService.getUserWithId(post.authorId),
//                         builder:
//                             (BuildContext context, AsyncSnapshot snapshot) {
//                           if (!snapshot.hasData) {
//                             return SizedBox.shrink();
//                           }

//                           AppUser? author = snapshot.data;

//                           return (post.imageUrl == null)
//                               ? TextPost(
//                                   postStatus: PostStatus.feedPost,
//                                   currentUserId: widget.currentUserId,
//                                   author: author,
//                                   post: post,
//                                 )
//                               : (post.videoUrl != null)
//                                   ? VideoPostView(
//                                       postStatus: PostStatus.feedPost,
//                                       currentUserId: widget.currentUserId,
//                                       author: author,
//                                       post: post,
//                                     )
//                                   : PostView(
//                                       postStatus: PostStatus.feedPost,
//                                       currentUserId: widget.currentUserId,
//                                       author: author,
//                                       post: post,
//                                     );
//                         },
//                       );
//                     }),
//               ),
//             );
//           })
//     ]);
//   }
// }
