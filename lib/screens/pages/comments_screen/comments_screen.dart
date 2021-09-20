import 'package:auto_direction/auto_direction.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/custom_navigation.dart';
import 'package:Dana/utilities/themes.dart';
import 'package:Dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsScreen extends StatefulWidget {
  final Post? post;
  final int? likeCount;
  final AppUser? author;
  final PostStatus postStatus;
  String? currentUserID;
  CommentsScreen(
      {this.post,
      this.likeCount,
      this.currentUserID,
      this.author,
      required this.postStatus});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

_goToUserProfile(BuildContext context, Comment comment, String? currentUserId) {
  CustomNavigation.navigateToUserProfile(
      context: context,
      currentUserId: currentUserId,
      userId: comment.authorId,
      isCameFromBottomNavigation: false);
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;
  int? commentCount = 0;

  _buildComment(Comment comment, String? currentUserId) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(comment.authorId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        AppUser author = snapshot.data;
        print(author.profileImageUrl);

        return _buildListTile(context, author, comment, currentUserId);
      },
    );
  }

  _buildListTile(BuildContext context, AppUser author, Comment comment,
      String? currentUserId) {
    return ListTile(
      leading: GestureDetector(
        onTap: () => _goToUserProfile(context, comment, currentUserId),
        child: CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.grey,
          backgroundImage: (author.profileImageUrl!.isEmpty
                  ? AssetImage(placeHolderImageRef)
                  : CachedNetworkImageProvider(author.profileImageUrl!))
              as ImageProvider<Object>?,
        ),
      ),
      title: GestureDetector(
          onTap: () => _goToUserProfile(context, comment, currentUserId),
          child: Row(
            children: [
              Text(author.name!,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              // UserBadges(user: widget.author, size: 15)
            ],
          )),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 6.0,
          ),
          Text(
            comment.content!,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 6.0,
          ),
          Text(timeago.format(comment.timestamp!.toDate()),
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  _buildCommentTF() {
    String hintText;
    if (widget.postStatus == PostStatus.feedPost) {
      if (widget.post!.commentsAllowed!) {
        hintText = 'Add a comment...';
      } else {
        hintText = 'Comment aren\'t allowed here...';
      }
    } else if (widget.postStatus == PostStatus.archivedPost) {
      hintText = 'This post was archived...';
    } else {
      hintText = 'This post was deleted...';
    }

    final profileImageUrl = Provider.of<UserData>(context, listen: false)
        .currentUser!
        .profileImageUrl;
    return IconTheme(
      data: IconThemeData(
        color: _isCommenting
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,
      ),
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 35, top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            profileImageUrl != null
                ? CircleAvatar(
                    radius: 15.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: (profileImageUrl.isEmpty
                            ? AssetImage(placeHolderImageRef)
                            : CachedNetworkImageProvider(profileImageUrl))
                        as ImageProvider<Object>?,
                  )
                : SizedBox.shrink(),
            SizedBox(width: 20.0),
            Expanded(
              child: AutoDirection(
                text: _commentController.text,
                child: TextField(
                  enabled: widget.post!.commentsAllowed! &&
                      widget.postStatus == PostStatus.feedPost,
                  controller: _commentController,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (comment) {
                    setState(() {
                      _isCommenting = comment.length > 0;
                    });
                  },
                  decoration: InputDecoration(
                    isCollapsed: true,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: hintText,
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Container(
              // margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                  onTap: widget.postStatus != PostStatus.feedPost ||
                          !widget.post!.commentsAllowed!
                      ? null
                      : () {
                          if (_isCommenting) {
                            DatabaseService.commentOnPost(
                              currentUserId: widget.currentUserID,
                              post: widget.post!,
                              comment: _commentController.text,
                              recieverToken: widget.author!.token,
                            );
                            _commentController.clear();
                            print(widget.currentUserID);
                            setState(() {
                              _isCommenting = false;
                              commentCount = commentCount! + 1;
                            });
                          }
                        },
                  child: Icon(FontAwesomeIcons.telegramPlane,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    commentCount = widget.post!.commentCount;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.currentUserID);
    Comment postDescription = Comment(
        authorId: widget.author!.id,
        content: widget.post!.caption,
        id: widget.post!.id,
        timestamp: widget.post!.timestamp);

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
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: darkColor,
              title: Text(
                'Comments',
                style: TextStyle(color: Colors.white),
              ),
              brightness: Brightness.dark,
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10.0),
                  _buildListTile(context, widget.author!, postDescription,
                      widget.currentUserID),
                  Divider(color: Colors.grey),
                  StreamBuilder(
                    stream: commentsRef
                        .doc(widget.post!.id)
                        .collection('postComments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(color: lightColor),
                        );
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            Comment comment =
                                Comment.fromDoc(snapshot.data.docs[index]);
                            return _buildComment(comment, widget.currentUserID);
                          },
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                  _buildCommentTF(),
                ],
              ),
            )),
      ],
    );
  }
}
