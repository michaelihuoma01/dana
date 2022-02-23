import 'dart:io';

import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:Dana/widgets/custom_modal_progress_hud.dart';
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

class UserPost extends StatefulWidget {
  final String? currentUserId;
  final String? authorId;
  final String? postId;
  final String? public;

  UserPost({this.currentUserId, this.authorId, this.postId, this.public});

  @override
  _UserPostState createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  bool _isLoading = false;
  var _future;

  AppUser? _currentUser;
  AppUser? _author;
  Post? _post;
  // Post? _publicPost;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupAll();
  }

  _setupAll() async {
    setState(() {
      _isLoading = true;
    });
    _currentUser = await DatabaseService.getUserWithId(widget.currentUserId);
    _author = await DatabaseService.getUserWithId(widget.authorId);

    if (widget.public == 'true') {
      _post = await DatabaseService.getPublicPost(widget.postId);
    } else {
      _post = await DatabaseService.getPost(widget.postId, widget.authorId);
    }
    setState(() {
      _isLoading = false;
    }); 
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
      (_isLoading)
          ? Center(child: CircularProgressIndicator.adaptive())
          : PickupLayout(
              currentUser: _currentUser,
              scaffold: Scaffold(
                  appBar: PreferredSize(
                    child: AppBar(
                      automaticallyImplyLeading: true,
                      backgroundColor: darkColor,
                      brightness: Brightness.dark,
                      centerTitle: true,
                      elevation: 5,
                      title: Text('${_author!.name!}\'s Post',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      iconTheme: IconThemeData(color: Colors.white),
                    ),
                    preferredSize: const Size.fromHeight(50),
                  ),
                  backgroundColor: Colors.transparent,
                  body: (_post!.imageUrl == null)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: TextPost(
                            postStatus: PostStatus.feedPost,
                            currentUserId: widget.currentUserId,
                            author: _author,
                            post: _post,
                          ),
                        )
                      : (_post!.videoUrl != null)
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: VideoPostView(
                                postStatus: PostStatus.feedPost,
                                currentUserId: widget.currentUserId,
                                author: _author,
                                post: _post,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: PostView(
                                postStatus: PostStatus.feedPost,
                                currentUserId: widget.currentUserId,
                                author: _author,
                                post: _post,
                              ),
                            )))
    ]);
  }
}
