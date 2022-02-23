import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/pages/comments_screen/comments_screen.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/custom_navigation.dart';
import 'package:Dana/utilities/themes.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:Dana/widgets/appbar_widget.dart';
import 'package:Dana/widgets/notifications_tile.dart';
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
                    : CachedNetworkImageProvider(user.profileImageUrl!))
                as ImageProvider<Object>?,
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
                        S.of(context)!.added,
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
                          '${S.of(context)!.commented}: "${activity.comment}',
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
                            S.of(context)!.liked,
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
    return WillPopScope(
      onWillPop: () {
        print('object');
        Navigator.pop(context, 'readNotifications');
        return Future.value(true);
      },
      child: Stack(children: [
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
        PickupLayout(
          currentUser: widget.currentUser,
          scaffold: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(70),
                  child:
                      AppBarWidget(isTab: false, title: S.of(context)!.notif)),
              body: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: RefreshIndicator(
                  onRefresh: () => _setupActivities(),
                  child: _isLoading
                      ? Center(
                          child: SpinKitFadingCircle(
                              color: Colors.white, size: 40))
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
              )),
        )
      ]),
    );
  }
}
