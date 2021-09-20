import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/screens/home.dart';
import 'package:Dana/screens/pages/camera_screen/nested_screens/create_post_screen.dart';
import 'package:Dana/screens/pages/comments_screen/comments_screen.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/custom_navigation.dart';
import 'package:Dana/utilities/themes.dart';
import 'package:Dana/utilities/zoomOverlay.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/common_widgets/heart_anime.dart';
import 'package:Dana/widgets/common_widgets/user_badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:math' as math; // import this

import 'package:http/http.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoPostView extends StatefulWidget {
  final String? currentUserId;
  final Post? post;
  final AppUser? author;
  final PostStatus postStatus;

  VideoPostView(
      {this.currentUserId, this.post, this.author, required this.postStatus});

  @override
  _VideoPostViewState createState() => _VideoPostViewState();
}

class _VideoPostViewState extends State<VideoPostView> {
  int? _likeCount = 0;
  int? _commentCount = 0;
  bool _isLiked = false;
  bool _heartAnim = false;
  bool _isPlaying = false;
  bool _isVisible = false;
  Post? _post;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post!.likeCount;
    _commentCount = widget.post!.commentCount;
    _post = widget.post;
    _initPostLiked();

    _controller = VideoPlayerController.network(_post!.videoUrl!)
      ..initialize().then((_) {
        // print('succesful folks');
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  didUpdateWidget(VideoPostView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post!.likeCount != _post!.likeCount) {
      _likeCount = widget.post!.likeCount;
      _commentCount = widget.post!.commentCount;
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
        currentUserId: widget.currentUserId, post: _post!);
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
          currentUserId: widget.currentUserId, post: _post!);
      setState(() {
        _isLiked = false;
        _likeCount = _likeCount! - 1;
      });
    } else {
      // Like Post
      DatabaseService.likePost(
          currentUserId: widget.currentUserId,
          post: _post!,
          receiverToken: widget.author!.token);
      setState(() {
        _heartAnim = true;
        _isLiked = true;
        _likeCount = _likeCount! + 1;
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
    final RenderBox box = context.findRenderObject() as RenderBox;

    var response = await get(Uri.parse(widget.post!.imageUrl!));
    final documentDirectory = (await getExternalStorageDirectory())!.path;
    File imgFile = new File('$documentDirectory/${widget.post!.id}.png');
    imgFile.writeAsBytesSync(response.bodyBytes);

    Share.shareFiles([imgFile.path],
        subject: 'Have a look at ${widget.author!.name} post!',
        text: '${widget.author!.name} : ${widget.post!.caption}',
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
              // SimpleDialogOption(
              //   child: Text('Share Post'),
              //   onPressed: () {
              //     _saveAndShareFile();
              //     Navigator.pop(context);
              //   },
              // ),
              // _post.authorId == widget.currentUserId &&
              //         widget.postStatus != PostStatus.archivedPost
              //     ? SimpleDialogOption(
              //         child: Text('Archive Post'),
              //         onPressed: () {
              //           DatabaseService.archivePost(
              //               widget.post, widget.postStatus);
              //           _goToHomeScreen(context);
              //         },
              //       )
              //     : SizedBox.shrink(),
              _post!.authorId == widget.currentUserId &&
                      widget.postStatus != PostStatus.deletedPost
                  ? SimpleDialogOption(
                      child: Text('Delete Post'),
                      onPressed: () {
                        DatabaseService.deletePost(_post!, widget.postStatus);
                        _goToHomeScreen(context);
                      },
                    )
                  : SizedBox.shrink(),
              // _post.authorId == widget.currentUserId &&
              //         widget.postStatus != PostStatus.feedPost
              //     ? SimpleDialogOption(
              //         child: Text('Show on profile'),
              //         onPressed: () {
              //           DatabaseService.recreatePost(_post, widget.postStatus);
              //           _goToHomeScreen(context);
              //         },
              //       )
              //     : SizedBox.shrink(),

              // _post.authorId == widget.currentUserId
              //     ? SimpleDialogOption(
              //         child: Text('Edit Post'),
              //         onPressed: () {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (_) => CreatePostScreen(
              //                 post: _post,
              //                 postStatus: widget.postStatus,
              //               ),
              //             ),
              //           );
              //         },
              //       )
              //     : SizedBox.shrink(),
              _post!.authorId == widget.currentUserId &&
                      widget.postStatus == PostStatus.feedPost
                  ? SimpleDialogOption(
                      child: Text(_post!.commentsAllowed!
                          ? 'Turn off commenting'
                          : 'Allow comments'),
                      onPressed: () {
                        DatabaseService.allowDisAllowPostComments(
                            _post!, !_post!.commentsAllowed!);
                        Navigator.pop(context);
                        setState(() {
                          _post = new Post(
                              authorId: widget.post!.authorId,
                              caption: widget.post!.caption,
                              commentsAllowed: !_post!.commentsAllowed!,
                              id: _post!.id,
                              imageUrl: _post!.imageUrl,
                              likeCount: _post!.likeCount,
                              location: _post!.location,
                              timestamp: _post!.timestamp);
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
    return IntrinsicWidth(
      child: GestureDetector(
        onTap: () {
          if (_isVisible == true) {
            setState(() {
              _isVisible = false;
            });
          } else {
            setState(() {
              _isVisible = true;
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onDoubleTap:
                  widget.postStatus == PostStatus.feedPost ? _likePost : () {},
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ZoomOverlay(
                      twoTouchOnly: true,
                      child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Hero(
                              tag: _post!.videoUrl!,
                              child: _controller.value.isInitialized
                                  ? AspectRatio(
                                      aspectRatio: 1 / 1,
                                      child: VideoPlayer(_controller),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 50, horizontal: 20),
                                      child: CircularProgressIndicator(
                                          color: lightColor),
                                    ),
                            ),
                          )),
                    ),
                  ),
                  _heartAnim ? HeartAnime(100.0) : SizedBox.shrink(),
                  Visibility(
                    visible: _isVisible,
                    child: GestureDetector(
                        onTap: () {
                          if (_controller.value.isPlaying) {
                            setState(() {
                              _controller.pause();
                              _isPlaying = true;
                            });
                          } else {
                            setState(() {
                              _controller.play();
                              _isPlaying = false;
                            });
                          }
                        },
                        child: Icon(
                            (_isPlaying) ? Icons.play_arrow : Icons.pause,
                            color: Colors.white,
                            size: 45)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: new LinearGradient(
                            end: const Alignment(0.0, -1),
                            begin: const Alignment(0.0, 0.6),
                            colors: <Color>[
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.0)
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 5),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => _goToUserProfile(context, _post!),
                                child: Container(
                                  height: 30,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    backgroundImage:
                                        (widget.author!.profileImageUrl!.isEmpty
                                            ? AssetImage(placeHolderImageRef)
                                            : CachedNetworkImageProvider(
                                                widget.author!.profileImageUrl!,
                                              )) as ImageProvider<Object>?,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.author!.name!,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700)),
                                  if (_post!.location != "")
                                    Text(_post!.location!,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.author!.id == widget.currentUserId)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Padding(
                          padding: const EdgeInsets.only(right: 20, bottom: 10),
                          child: GestureDetector(
                            child: Icon(Icons.more_vert, color: Colors.white),
                            onTap: () {
                              _showMenuDialog();
                            },
                          )),
                    )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Row(
                          children: [
                            SizedBox(width: 8),
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
                                child: Icon(Icons.chat_bubble_outline,
                                    color: Colors.white),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentsScreen(
                                      postStatus: widget.postStatus,
                                      post: _post,
                                      likeCount: _likeCount,
                                      author: widget.author,
                                      currentUserID: widget.currentUserId),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_likeCount != 0)
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                              '${NumberFormat.compact().format(_likeCount)} ${_likeCount == 1 ? 'like' : 'likes'}',
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.white))),
                    SizedBox(height: 4.0),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(
                            left: 12.0,
                            right: 6.0,
                          ),
                          child: GestureDetector(
                            onTap: () => _goToUserProfile(context, _post!),
                            child: Row(
                              children: [
                                Text(
                                  widget.author!.name!,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                // UserBadges(
                                //     user: widget.author,
                                //     size: 15,
                                //     secondSizedBox: false)
                              ],
                            ),
                          ),
                        ),
                        if (_post!.caption != "")
                          Expanded(
                              child: Text(
                            _post!.caption!,
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          )),
                      ],
                    ),
                    SizedBox(height: 5),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                                'View ${NumberFormat.compact().format(_commentCount)} ${_commentCount == 1 ? 'comment' : 'comments'}',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey))),
                      ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5.0),
                        child: Text(timeago.format(_post!.timestamp!.toDate()),
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12.0))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
