import 'dart:math';

import 'package:auto_direction/auto_direction.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/models/models.dart';
import 'package:dana/models/story_model.dart';
import 'package:dana/models/user_data.dart';
import 'package:dana/models/user_model.dart';
import 'package:dana/screens/pages/stories_screen/widgets/animated_bar.dart';
import 'package:dana/screens/pages/stories_screen/widgets/story_info.dart';
import 'package:dana/services/api/chat_service.dart';
import 'package:dana/services/api/database_service.dart';
import 'package:dana/services/api/stories_service.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utilities/custom_navigation.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/utils/utility.dart';
import 'package:dana/widgets/BrandDivider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class StoryScreen extends StatefulWidget {
  final List<Story> stories;
  final AppUser user;

  final int seenStories;
  const StoryScreen(
      {@required this.stories,
      @required this.user,
      @required this.seenStories});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  AnimationController _animController;
  int _currentIndex = 0;
  DragStartDetails startVerticalDragDetails;
  DragUpdateDetails updateVerticalDragDetails;
  int _seenStories;
  List<AppUser> viewersList = [];
  List viewersTime = [];
  int views;
  final TextEditingController _messageController = TextEditingController();
  FocusNode focusNode = FocusNode();
  AppUser currentUser;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);
    setState(() => _seenStories = widget.seenStories);

    if (_seenStories != 0 && _seenStories != widget.stories.length) {
      _pageController = PageController(initialPage: _seenStories);
      setState(() => _currentIndex = _seenStories);
      _loadStory(story: widget.stories[_seenStories], animateToPage: false);
    } else {
      final Story firstStory = widget.stories.first;
      _loadStory(story: firstStory, animateToPage: false);
    }

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex++;
            _loadStory(story: widget.stories[_currentIndex]);
          } else {
            // if the stories ended...
            Navigator.of(context).pop(_currentIndex);
            // _currentIndex = 0;
            // _loadStory(story: widget.stories[_currentIndex]);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _animController?.dispose();
    super.dispose();
  }

  _sendMessage(
      {String text,
      String imageUrl,
      String giphyUrl,
      String audioUrl,
      String videoUrl,
      String fileUrl,
      String fileName,
      AppUser receiver}) async {
    if ((text != null && text.trim().isNotEmpty) ||
        (fileName != null && fileName.trim().isNotEmpty) ||
        imageUrl != null ||
        audioUrl != null ||
        videoUrl != null ||
        fileUrl != null ||
        giphyUrl != null) {
      setState(() => isSending = true);

      List<String> userIds = [];
      userIds.add(currentUser.id);
      userIds.add(receiver.id);

      Chat chat = await ChatService.getChatByUsers(userIds);

      bool isChatExist = chat != null;

      if (!isChatExist) {
        chat = await ChatService.createChat([currentUser, receiver], userIds);

        setState(() {
          isChatExist = true;
        });
      }

      if (imageUrl == null &&
          giphyUrl == null &&
          audioUrl == null &&
          videoUrl == null &&
          fileUrl == null) {
        _messageController.clear();
      }

      Message message = Message(
        senderId: currentUser.id,
        text: text,
        imageUrl: imageUrl,
        fileName: fileName,
        giphyUrl: giphyUrl,
        audioUrl: audioUrl,
        videoUrl: videoUrl,
        fileUrl: fileUrl,
        timestamp: Timestamp.now(),
        isLiked: false,
      );

      ChatService.sendChatMessage(chat, message, receiver);
      chatsRef.doc(chat.id).update({'readStatus.${receiver.id}': false});
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    currentUser = Provider.of<UserData>(context).currentUser;
    bool isCurrentUser = currentUser.id == widget.user.id ? true : false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragStart: (dragDetails) {
          startVerticalDragDetails = dragDetails;
        },
        onVerticalDragUpdate: (dragDetails) {
          updateVerticalDragDetails = dragDetails;
        },
        onVerticalDragEnd: (endDetails) {
          double dx = updateVerticalDragDetails.globalPosition.dx -
              startVerticalDragDetails.globalPosition.dx;
          double dy = updateVerticalDragDetails.globalPosition.dy -
              startVerticalDragDetails.globalPosition.dy;
          double velocity = endDetails.primaryVelocity;

          //Convert values to be positive
          if (dx < 0) dx = -dx;
          if (dy < 0) dy = -dy;

          if (velocity < 0) {
            //swipe Up
            _onSwipeUp();
          } else {
            //swipe down
            Navigator.of(context).pop(_currentIndex);
          }
        },
        // onTapDown: (detailes) => _onTapDown(detailes),
        child: PageView.builder(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.stories.length,
          itemBuilder: (context, index) {
            final Story story = widget.stories[index];

            StoriesService.setNewStoryView(currentUser.id, story);

            return Stack(
              children: [
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    int sensitivity = 8;
                    if (details.delta.dy > sensitivity) {
                      // Down Swipe
                      print('swiped down');
                      Navigator.pop(context);
                    } else if (details.delta.dy < -sensitivity) {
                      // Up Swipe
                      print('swiped up');
                      if (isCurrentUser)
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                color: darkColor,
                                height: 500,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 15, bottom: 5),
                                      child: Text('Viewers',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                    ),
                                    BrandDivider(),
                                    Expanded(
                                      child: Container(
                                        child: ListView.builder(
                                            itemCount: story.views.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              AppUser viewers =
                                                  viewersList[index];
                                              var timeSeen = viewersTime[index];

                                              return (viewers.id !=
                                                      currentUser.id)
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      child: ListTile(
                                                        onTap: () {
                                                          CustomNavigation
                                                              .navigateToUserProfile(
                                                            context: context,
                                                            appUser: viewers,
                                                            userId: viewers.id,
                                                            currentUserId:
                                                                currentUser.id,
                                                            isCameFromBottomNavigation:
                                                                false,
                                                          );
                                                        },
                                                        leading: Container(
                                                          height: 40,
                                                          width: 40,
                                                          child: CircleAvatar(
                                                            radius: 25.0,
                                                            backgroundColor:
                                                                Colors.grey,
                                                            backgroundImage: viewers
                                                                    .profileImageUrl
                                                                    .isEmpty
                                                                ? AssetImage(
                                                                    placeHolderImageRef)
                                                                : CachedNetworkImageProvider(
                                                                    viewers
                                                                        .profileImageUrl),
                                                          ),
                                                        ),
                                                        title: Text(
                                                            viewers.name,
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .white)),
                                                        subtitle: Text(
                                                            'PIN: ${viewers.pin}',
                                                            maxLines: 3,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 13)),
                                                        trailing: Text(
                                                            timeago.format(
                                                                timeSeen
                                                                    .toDate()),
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    )
                                                  : SizedBox.shrink();
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      else {
                        setState(() {
                          focusNode.requestFocus();
                        });
                      }
                    }
                  },
                  child: CachedNetworkImage(
                    imageUrl: story.imageUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 500),
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return Center(
                        child: CircularProgressIndicator(
                            color: lightColor,
                            value: downloadProgress.progress),
                      );
                    },
                  ),
                ),
                if (isCurrentUser)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                color: darkColor,
                                height: 500,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 15, bottom: 5),
                                      child: Text('Viewers',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                    ),
                                    BrandDivider(),
                                    Expanded(
                                      child: Container(
                                        child: ListView.builder(
                                            itemCount: story.views.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              AppUser viewers =
                                                  viewersList[index];
                                              var timeSeen = viewersTime[index];

                                              return (viewers.id !=
                                                      currentUser.id)
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      child: ListTile(
                                                        onTap: () {
                                                          CustomNavigation
                                                              .navigateToUserProfile(
                                                            context: context,
                                                            appUser: viewers,
                                                            userId: viewers.id,
                                                            currentUserId:
                                                                currentUser.id,
                                                            isCameFromBottomNavigation:
                                                                false,
                                                          );
                                                        },
                                                        leading: Container(
                                                          height: 40,
                                                          width: 40,
                                                          child: CircleAvatar(
                                                            radius: 25.0,
                                                            backgroundColor:
                                                                Colors.grey,
                                                            backgroundImage: viewers
                                                                    .profileImageUrl
                                                                    .isEmpty
                                                                ? AssetImage(
                                                                    placeHolderImageRef)
                                                                : CachedNetworkImageProvider(
                                                                    viewers
                                                                        .profileImageUrl),
                                                          ),
                                                        ),
                                                        title: Text(
                                                            viewers.name,
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .white)),
                                                        subtitle: Text(
                                                            'PIN: ${viewers.pin}',
                                                            maxLines: 3,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 13)),
                                                        trailing: Text(
                                                            timeago.format(
                                                                timeSeen
                                                                    .toDate()),
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    )
                                                  : SizedBox.shrink();
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      child: Container(
                        height: 40,
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.eye,
                                  size: 15, color: Colors.white),
                              SizedBox(width: 5),
                              Text('${story.views.length - 1}',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18))
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: AutoDirection(
                                text: _messageController.text,
                                child: TextField(
                                  minLines: 1,
                                  maxLines: 3,
                                  style: TextStyle(color: Colors.white),
                                  cursorColor: lightColor,
                                  controller: _messageController,
                                  focusNode: focusNode,
                                  textInputAction: TextInputAction.done,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onChanged: (messageText) {},
                                  decoration: InputDecoration(
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      hintStyle: TextStyle(color: Colors.grey),
                                      hintText: 'Reply...'),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                AppUser receiver =
                                    await DatabaseService.getUserWithId(
                                        story.authorId);
                                 
                                _sendMessage(
                                    text: _messageController.text.trim(),
                                    receiver: receiver,
                                    imageUrl: null,
                                    giphyUrl: null,
                                    audioUrl: null,
                                    videoUrl: null,
                                    fileName: null,
                                    fileUrl: null);
                                     Utility.showMessage(context,
          message: 'Reply sent',
          pulsate: false,
          bgColor: Colors.green[600]);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: lightColor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(Ionicons.send,
                                        color: darkColor, size: 15),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 40.0,
                  left: 10.0,
                  right: 10.0,
                  child: Column(
                    children: [
                      Row(
                        children: widget.stories
                            .asMap()
                            .map((i, e) {
                              return MapEntry(
                                  i,
                                  AnimatedBar(
                                    animationController: _animController,
                                    position: i,
                                    currentIndex: _currentIndex,
                                  ));
                            })
                            .values
                            .toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 1.5, vertical: 10.0),
                        child: StoryInfo(
                          onSwipeUp: () => _onSwipeUp(),
                          height: size.height - 100,
                          user: widget.user,
                          story: widget.stories[_currentIndex],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  void _onSwipeUp() async {
    if (widget.stories[_currentIndex].linkUrl != '') {
      String url = widget.stories[_currentIndex].linkUrl;
      if (await canLaunch(url)) {
        await launch(
          url,
          forceSafariVC: true,
          forceWebView: true,
          enableJavaScript: true,
        );
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  void _onTapDown(TapDownDetails details) {
    print("Holdinggggg");
    final Size screenSize = MediaQuery.of(context).size;
    final double dx = details.globalPosition.dx;

    if (dx < screenSize.width / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex--;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    } else if (dx > 2 * screenSize.width / 3) {
      setState(() {
        if (_currentIndex + 1 < widget.stories.length) {
          _currentIndex++;
          _loadStory(story: widget.stories[_currentIndex]);
        } else {
          Navigator.of(context).pop(_currentIndex);
        }
      });
    } else {}
  }

  void _loadStory({Story story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    _animController.duration = Duration(seconds: story.duration ?? 10);
    _animController.forward();

    if (animateToPage) {
      _pageController.animateToPage(_currentIndex,
          duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
    }

    story.views.keys.forEach((element) async {
      viewersList.add(await DatabaseService.getUserWithId(element));
    });

    story.views.values.forEach((element) async {
      viewersTime.add(element);
    });
  }
}
