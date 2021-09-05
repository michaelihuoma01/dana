import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dana/models/models.dart';
import 'package:dana/screens/home.dart';
import 'package:dana/screens/pages/camera_screen/nested_screens/create_post_screen.dart';
import 'package:dana/screens/pages/comments_screen/comments_screen.dart';
import 'package:dana/services/services.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utilities/custom_navigation.dart';
import 'package:dana/utilities/themes.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/BrandDivider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:math' as math; // import this

class TextPost extends StatefulWidget {
  final String currentUserId;
  final Post post;
  final AppUser author;
  final PostStatus postStatus;

  TextPost(
      {this.currentUserId, this.post, this.author, @required this.postStatus});
  @override
  _TextPostState createState() => _TextPostState();
}

class _TextPostState extends State<TextPost> {
  int _likeCount = 0;
  int _commentCount = 0;
  bool _isLiked = false;
  bool _heartAnim = false;
  Post _post;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _commentCount = widget.post.commentCount;

    _post = widget.post;
    _initPostLiked();
  }

  @override
  didUpdateWidget(TextPost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.likeCount != _post.likeCount) {
      _likeCount = widget.post.likeCount;
      _commentCount = widget.post.commentCount;
    }
  }

  _goToUserProfile(BuildContext context, Post post) {
    CustomNavigation.navigateToUserProfile(
        context: context,
        currentUserId: widget.currentUserId,
        userId: post.authorId,
        isCameFromBottomNavigation: false);
  }

  _initPostLiked() async {
    bool isLiked = await DatabaseService.didLikePost(
        currentUserId: widget.currentUserId, post: _post);
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  _likePost() {
    if (_isLiked) {
      // Unlike Post
      DatabaseService.unlikePost(
          currentUserId: widget.currentUserId, post: _post);
      setState(() {
        _isLiked = false;
        _likeCount--;
      });
    } else {
      // Like Post
      DatabaseService.likePost(
          currentUserId: widget.currentUserId,
          post: _post,
          receiverToken: widget.author.token);
      setState(() {
        _heartAnim = true;
        _isLiked = true;
        _likeCount++;
      });
      Timer(Duration(milliseconds: 350), () {
        setState(() {
          _heartAnim = false;
        });
      });
    }
  }

  _goToHomeScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) => HomeScreen(
                currentUserId: widget.currentUserId,
              )),
      (Route<dynamic> route) => false,
    );
  }

  _showMenuDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _saveAndShareFile() async {
    final RenderBox box = context.findRenderObject();

    var response = await get(Uri.parse(widget.post.imageUrl));
    final documentDirectory = (await getExternalStorageDirectory()).path;
    File imgFile = new File('$documentDirectory/${widget.post.id}.png');
    imgFile.writeAsBytesSync(response.bodyBytes);

    Share.shareFiles([imgFile.path],
        subject: 'Have a look at ${widget.author.name} post!',
        text: '${widget.author.name} : ${widget.post.caption}',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text('Add Photo'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                onPressed: () {},
                child: Text('Take Photo'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {},
                child: Text('Choose From Gallery'),
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text(
                'Cancel',
                style: kFontColorRedTextStyle,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          );
        });
  }

  _androidDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            // title: Text('Add Photo'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Share Post'),
                onPressed: () {
                  _saveAndShareFile();
                  Navigator.pop(context);
                },
              ),
              _post.authorId == widget.currentUserId &&
                      widget.postStatus != PostStatus.archivedPost
                  ? SimpleDialogOption(
                      child: Text('Archive Post'),
                      onPressed: () {
                        DatabaseService.archivePost(
                            widget.post, widget.postStatus);
                        _goToHomeScreen(context);
                      },
                    )
                  : SizedBox.shrink(),
              _post.authorId == widget.currentUserId &&
                      widget.postStatus != PostStatus.deletedPost
                  ? SimpleDialogOption(
                      child: Text('Delete Post'),
                      onPressed: () {
                        DatabaseService.deletePost(_post, widget.postStatus);
                        _goToHomeScreen(context);
                      },
                    )
                  : SizedBox.shrink(),
              _post.authorId == widget.currentUserId &&
                      widget.postStatus != PostStatus.feedPost
                  ? SimpleDialogOption(
                      child: Text('Show on profile'),
                      onPressed: () {
                        DatabaseService.recreatePost(_post, widget.postStatus);
                        _goToHomeScreen(context);
                      },
                    )
                  : SizedBox.shrink(),

              _post.authorId == widget.currentUserId
                  ? SimpleDialogOption(
                      child: Text('Edit Post'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreatePostScreen(
                              post: _post,
                              postStatus: widget.postStatus,
                            ),
                          ),
                        );
                      },
                    )
                  : SizedBox.shrink(),
              _post.authorId == widget.currentUserId &&
                      widget.postStatus == PostStatus.feedPost
                  ? SimpleDialogOption(
                      child: Text(_post.commentsAllowed
                          ? 'Turn off commenting'
                          : 'Allow comments'),
                      onPressed: () {
                        DatabaseService.allowDisAllowPostComments(
                            _post, !_post.commentsAllowed);
                        Navigator.pop(context);
                        setState(() {
                          _post = new Post(
                              authorId: widget.post.authorId,
                              caption: widget.post.caption,
                              commentsAllowed: !_post.commentsAllowed,
                              id: _post.id,
                              imageUrl: _post.imageUrl,
                              likeCount: _post.likeCount,
                              location: _post.location,
                              timestamp: _post.timestamp);
                        });
                      },
                    )
                  : SizedBox.shrink(),
              // SimpleDialogOption(
              //   child: Text('Download Image'),
              //   onPressed: () async {
              //     await ImageDownloader.downloadImage(
              //       _post.imageUrl,
              //       outputMimeType: "image/jpg",
              //     );
              //     Navigator.pop(context);
              //   },
              // ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              height: 35,
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: widget.author.profileImageUrl.isEmpty
                    ? AssetImage(placeHolderImageRef)
                    : CachedNetworkImageProvider(
                        widget.author.profileImageUrl,
                      ),
              ),
            ),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.author.name,
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              Text(timeago.format(_post.timestamp.toDate()),
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ]),
          SizedBox(height: 8),
          Text(_post.caption,
              style: TextStyle(color: Colors.white, fontSize: 16)),
          SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                child: _isLiked
                    ? Icon(
                        Icons.favorite,
                        size: 28,
                        color: lightColor,
                      )
                    : Icon(Icons.favorite_outline,
                        color: Colors.white, size: 30),
                onTap: widget.postStatus == PostStatus.feedPost
                    ? _likePost
                    : () {},
              ),
              SizedBox(width: 8),
              GestureDetector(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Icon(Icons.chat_bubble_outline, color: Colors.white),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CommentsScreen(
                          postStatus: widget.postStatus,
                          post: _post,
                          likeCount: _likeCount,
                          author: widget.author,
                          currentUserID: widget.currentUserId)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (_likeCount != 0)
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Text(
                '${NumberFormat.compact().format(_likeCount)} ${_likeCount == 1 ? 'like' : 'likes'}',
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          SizedBox(height: 3),

          if (_commentCount != 0)
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CommentsScreen(
                          postStatus: widget.postStatus,
                          post: _post,
                          likeCount: _likeCount,
                          author: widget.author,
                          currentUserID: widget.currentUserId))),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Text(
                      'View ${NumberFormat.compact().format(_commentCount)} ${_commentCount == 1 ? 'comment' : 'comments'}',
                      style: TextStyle(fontSize: 13, color: Colors.grey))),
            ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
