import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/models/models.dart';
import 'package:dana/models/user_model.dart';
import 'package:dana/screens/pages/comments_screen/comments_screen.dart';
import 'package:dana/services/services.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utilities/custom_navigation.dart';
import 'package:dana/utilities/themes.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/BrandDivider.dart';
import 'package:dana/widgets/appbar_widget.dart';
import 'package:dana/widgets/notifications_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  AppUser? currentUser;

  NotificationsScreen({this.currentUser});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Activity> _activities = [];
  bool _isLoading = false;
  late var stream;
  @override
  @override
  void initState() {
    super.initState();
    _setupActivities();
  }

  _setupActivities() async {
    setState(() => _isLoading = true);
    List<Activity> activities =
        await DatabaseService.getActivities(widget.currentUser!.id);
    if (mounted) {
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    stream.cancel();

    super.dispose();
  }

  _buildActivity(Activity activity) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(activity.fromUserId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        AppUser user = snapshot.data;
        return ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            backgroundImage: ((user.profileImageUrl == null)
                ? AssetImage(placeHolderImageRef)
                : CachedNetworkImageProvider(user.profileImageUrl!)) as ImageProvider<Object>?,
          ),
          title: activity.isFollowEvent == true
              ? Row(
                  children: <Widget>[
                    Text('${user.name}',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'added you as a friend',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              : activity.isCommentEvent == true
                  ? Row(
                      children: <Widget>[
                        Text('${user.name}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        SizedBox(width: 5),
                        Expanded(
                            child: Text(
                          'commented: "${activity.comment}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white),
                        )),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        Text('${user.name}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'liked your post',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
          subtitle: Text(
            timeago.format(activity.timestamp!.toDate()),
            style: TextStyle(color: Colors.grey),
          ),
          trailing: activity.postImageUrl == null
              ? SizedBox.shrink()
              : CachedNetworkImage(
                  imageUrl: activity.postImageUrl!,
                  fadeInDuration: Duration(milliseconds: 500),
                  height: 40.0,
                  width: 40.0,
                  fit: BoxFit.cover),
          onTap: activity.isFollowEvent!
              ? () => CustomNavigation.navigateToUserProfile(
                  context: context,
                  currentUserId: widget.currentUser!.id,
                  isCameFromBottomNavigation: false,
                  userId: activity.fromUserId)
              : () async {
                  Post post = await DatabaseService.getUserPost(
                    widget.currentUser!.id,
                    activity.postId,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(
                        postStatus: PostStatus.feedPost,
                        post: post,
                        likeCount: post.likeCount,
                        author: widget.currentUser,
                      ),
                    ),
                  );
                },
        );
      },
    );
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
              preferredSize: const Size.fromHeight(70),
              child: AppBarWidget(isTab: false, title: 'Notifications')),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: RefreshIndicator(
              onRefresh: () => _setupActivities(),
              child: _isLoading
                  ? Center(
                      child:
                          SpinKitWanderingCubes(color: Colors.white, size: 40))
                  : ListView.builder(
                      itemCount: _activities.length,
                      itemBuilder: (BuildContext context, int index) {
                        Activity activity = _activities[index];
                        if (activity.isMessageEvent == true ||
                            activity.isLikeMessageEvent == true) {
                          return SizedBox.shrink();
                        }
                        return _buildActivity(activity);
                      },
                    ),
            ),
          ))
    ]);
  }
}
