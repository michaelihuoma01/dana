import 'dart:async';
import 'dart:io';

import 'package:Dana/calls/call.dart';
import 'package:Dana/calls/call_methods.dart';
import 'package:Dana/calls/callscreens/call_screen.dart';
import 'package:Dana/calls/constants/strings.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/screens/pages/user_post.dart';
import 'package:Dana/services/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/chat_model.dart';
import 'package:Dana/models/user_data.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/auth/login.dart';
import 'package:Dana/screens/auth/register.dart';
import 'package:Dana/screens/pages/camera_screen/camera_screen.dart';
import 'package:Dana/screens/tabs/calls_screen.dart';
import 'package:Dana/screens/tabs/contacts_screen.dart';
import 'package:Dana/screens/tabs/feeds_screen.dart';
import 'package:Dana/screens/tabs/messages_screen.dart';
import 'package:Dana/screens/tabs/profile_screen.dart';
import 'package:Dana/services/api/auth_service.dart';
import 'package:Dana/services/api/database_service.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/show_error_dialog.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/utils/shared_preferences_utils.dart';
import 'package:Dana/utils/utility.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'HomeScreen';

  // final AppUser currentUser;
  final String? currentUserId;
  final int initialPage;
  final List<CameraDescription>? cameras;
  HomeScreen({this.currentUserId, this.initialPage = 1, this.cameras});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  int _currentTab = 0;
  int _currentPage = 0;
  int _lastTab = 0;
  PageController? _pageController;
  AppUser? _currentUser;
  List<CameraDescription>? _cameras;
  CameraConsumer _cameraConsumer = CameraConsumer.post;
  final ScrollController homeController = ScrollController();

  AppUser? user;
  TabController? tabController;
  int selectedIndex = 0;
  bool isSelected1 = true,
      isSelected2 = false,
      isSelected3 = false,
      isSelected4 = false,
      isSelected5 = false;
  List<AppUser> _friends = [];
  List<AppUser> _requests = [];
  List<AppUser> _friendRequests = [];

  bool _isLoading = false;
  List<bool> _userFollowersState = [];
  List<bool> _userFollowingState = [];
  int _followingCount = 0;
  int _followersCount = 0;
  bool isFollower = false;
  bool isFollowingUser = false;
  bool isFriends = false;
  StreamSubscription<ConnectivityResult>? subscription;
  CallMethods callMethods = CallMethods();
  CollectionReference callCollection =
      FirebaseFirestore.instance.collection(CALL_COLLECTION);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Got a new connectivity status!

      if (result == ConnectivityResult.none) {
        Utility.showMessage(context,
            bgColor: Colors.red,
            message: 'No Internet Connection',
            pulsate: false,
            duration: Duration(seconds: 2),
            type: MessageTypes.error);
      } else {}
    });
    _getCurrentUser();
    _getCameras();
    checkUnreadMessages();
    _setupFriends();
    initDynamicLinks();
    // _initPageView();
    AuthService.updateToken();
    tabController = TabController(length: 5, vsync: this);
    tabController!.addListener(() {
      onItemClicked(tabController!.index);
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    subscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //TODO: set status to online here in firestore
      DatabaseService.updateStatusOnline(widget.currentUserId);
    } else {
      //TODO: set status to offline here in firestore

      DatabaseService.updateStatusOffline(widget.currentUserId);
    }
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
      String? currentUserId = deepLink.queryParameters['userId'];
      String? postId = deepLink.queryParameters['postId'];
      String? authorId = deepLink.queryParameters['authorId'];
      String? public = deepLink.queryParameters['public'];
      String? joinCall = deepLink.queryParameters['joinCall'];
      String? video = deepLink.queryParameters['video'];

      bool isAudio = false;

      var snaps = await callMethods
          .joinCall(uid: 'eTsAImJDPTfHXE7FPu6mRyyHINF2')
          .then((value) => print(value.id));

      if (joinCall != null) {
        if (video == 'true') {
          isAudio = false;
        } else {
          isAudio = true;
        }

        Call call = Call(channelId: joinCall);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CallScreen(
                  currentUserId: currentUserId,
                  call: call,
                  isAudio: isAudio,
                )));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UserPost(
                currentUserId: currentUserId,
                authorId: authorId,
                postId: postId,
                public: public)));
      }
    }
    FirebaseDynamicLinks.instance.onLink.listen((event) async {
      DocumentSnapshot callSnapshot =
          await callCollection.doc('eTsAImJDPTfHXE7FPu6mRyyHINF2').get();
      Call call = Call.fromMap(callSnapshot);

      String? currentUserId = event.link.queryParameters['userId'];
      String? postId = event.link.queryParameters['postId'];
      String? authorId = event.link.queryParameters['authorId'];
      String? public = event.link.queryParameters['public'];
      String? joinCall = event.link.queryParameters['joinCall'];
      String? video = event.link.queryParameters['video'];

      bool isAudio = false;

      if (joinCall != null) {
        if (video == 'true') {
          isAudio = true;
        } else {
          isAudio = false;
        }
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CallScreen(
                  currentUserId: currentUserId,
                  call: call,
                  isAudio: isAudio,
                )));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UserPost(
                currentUserId: currentUserId,
                authorId: authorId,
                postId: postId,
                public: public)));
      }

      print('--------------------------------------');

      print(currentUserId);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => UserPost(
              currentUserId: currentUserId,
              authorId: authorId,
              postId: postId,
              public: public)));
    }).onError((e) async {
      print("deeplink error");
      print(e.message);
    });
  }

  _setupFriends() async {
    List<String?> followingUsers =
        await DatabaseService.getUserFollowingIds(widget.currentUserId);

    List<String?> followerUsers =
        await DatabaseService.getUserFollowersIds(widget.currentUserId);

    var friendList = [...followingUsers, ...followerUsers].toSet().toList();

    for (String? userId in friendList) {
      var isFollowing = await DatabaseService.isUserFollower(
        currentUserId: widget.currentUserId,
        userId: userId,
      );

      var isFollower = await DatabaseService.isUserFollower(
        currentUserId: userId,
        userId: widget.currentUserId,
      );

      var friends = await DatabaseService.getUserWithId(userId);

      if (isFollower == true && isFollowing == true) {
        isFriends = true;
        _friends.add(friends);
      } else if (isFollowing == false && isFollower == true) {
        isHomeRequest = true;
        _requests.add(friends);
      }
    }

    Provider.of<UserData>(context, listen: false).friends = _friends;
    Provider.of<UserData>(context, listen: false).requests = _requests;
  }

  checkUnreadMessages() async {
    Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('chats')
        .where('memberIds', arrayContains: widget.currentUserId)
        // .orderBy('recentTimestamp', descending: true)
        .snapshots();

    await for (QuerySnapshot q in stream) {
      for (var doc in q.docs) {
        Chat chatFromDoc = Chat.fromDoc(doc);
        if (chatFromDoc.readStatus[widget.currentUserId] == true) {
          setState(() {
       
            isRead = true;
          });
        } else {
          setState(() {
            isRead = false;
          });
        }
      }
    }
  }

  Future<Null> _getCameras() async {
    if (widget.cameras != null) {
      setState(() {
        _cameras = widget.cameras;
      });
    } else {
      try {
        _cameras = await availableCameras().then((value) {
          print('object $value');
          return value;
        });
      } on CameraException catch (_) {
        ShowErrorDialog.showAlertDialog(
            errorMessage: 'Cant get cameras!', context: context);
      }
    }
  }

  void _selectTab(int index) {
    if (index == 2) {
      // go to CameraScreen
      // _pageController.animateToPage(0,
      //     duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      // _selectPage(2);
    }
    setState(() {
      _lastTab = _currentTab;
      _currentTab = index;
    });
  }

  void _getCurrentUser() async {
    setState(() {
      _isLoading = true;
    });
    AppUser currentUser =
        await DatabaseService.getUserWithId(widget.currentUserId);

    if (currentUser == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    Provider.of<UserData>(context, listen: false).currentUser = currentUser;

    setState(() => _currentUser = currentUser);
    AuthService.updateTokenWithUser(currentUser);
    print('=====||||||||||||||=========Fetching feeds');
    // Fetching Feeds
    List<Post> posts =
        await DatabaseService.getAllFeedPosts(context, currentUser);
    posts.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    // Fetching Stories
    List<AppUser> followingUsers =
        await DatabaseService.getUserFollowingUsers(widget.currentUserId);
    print('=====||||||||||||||=========${posts.length}');
    Provider.of<UserData>(context, listen: false).feeds = posts;
    Provider.of<UserData>(context, listen: false).stories = followingUsers;

    setState(() {
      _isLoading = false;
    });
  }

  void _selectPage(int index) {
    if (index == 1 && _currentTab == 2) {
      // Come back from CameraScreen to FeedScreen
      _selectTab(_lastTab);
      if (_cameraConsumer != CameraConsumer.post) {
        setState(() => _cameraConsumer = CameraConsumer.post);
      }
    }
  }

  void _goToCameraScreen() {
    setState(() => _cameraConsumer = CameraConsumer.story);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CameraScreen(
                _cameras, _backToHomeScreenFromCameraScreen, _cameraConsumer)));
    // _pageController.animateToPage(0,
    //     duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void _backToHomeScreenFromCameraScreen() {
    _selectPage(1);
    _pageController!.animateToPage(1,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController?..index = selectedIndex;
      switch (index) {
        case 0:
          isSelected1 = true;
          isSelected2 = false;
          isSelected3 = false;
          isSelected4 = false;
          isSelected5 = false;
          homeController.animateTo(0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
          break;
        case 1:
          isSelected1 = false;
          setState(() {
            isRead = true;
          });
          isSelected2 = true;
          isSelected3 = false;
          isSelected4 = false;
          isSelected5 = false;
          break;
        case 2:
          isSelected1 = false;
          isSelected2 = false;
          isSelected3 = true;
          
          isSelected4 = false;
          isSelected5 = false;
          break;
        case 3:
          isSelected1 = false;
          isSelected2 = false;
          isSelected3 = false;
          isSelected4 = true;
          isSelected5 = false;
          break;
        case 4:
          isSelected1 = false;
          isSelected2 = false;
          isSelected3 = false;
          isSelected4 = false;
          isSelected5 = true;
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        PickupLayout(
          currentUser: _currentUser,
          scaffold: Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: GestureDetector(
                        // onTap: () {
                        //   if (isSelected1 == true && selectedIndex == 0) {
                        //     homeController.animateTo(0.0,
                        //         duration: const Duration(milliseconds: 300),
                        //         curve: Curves.easeOut);
                        //   } else {
                        //     // onItemClicked(selectedIndex);
                        //   }
                        // },
                        child: SvgPicture.asset('assets/images/feeds.svg',
                            color: isSelected1 ? lightColor : Colors.grey,  height: 18),
                      ),
                      title: Text(isSelected1 ? S.of(context)!.feeds : '',
                          style: TextStyle(
                              fontSize: 10,
                              color: isSelected1
                                  ? lightColor
                                  : Colors.transparent))),
                  BottomNavigationBarItem(
                      icon: Column(
                        children: [
                          if (isRead == false)
                            Icon(Icons.circle, color: Colors.red, size: 6),
                          SizedBox(height: 3),
                          SvgPicture.asset('assets/images/message.svg',
                              color: isSelected2 ? lightColor : Colors.grey, height: 18),
                        ],
                      ),
                      title: Text(isSelected2 ? S.of(context)!.messages : '',
                          style: TextStyle(
                              fontSize: 10,
                              color: isSelected2
                                  ? lightColor
                                  : Colors.transparent))),
                  BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/images/call.svg',
                          color: isSelected3 ? lightColor : Colors.grey,  height: 18),
                      title: Text(isSelected3 ? S.of(context)!.calls : '',
                          style: TextStyle(
                              fontSize: 10,
                              color: isSelected3
                                  ? lightColor
                                  : Colors.transparent))),
                  BottomNavigationBarItem(
                      icon: Column(
                        children: [
                          if (isHomeRequest == true)
                            Icon(Icons.circle, color: Colors.red, size: 6),
                          SizedBox(height: 3),
                          SvgPicture.asset('assets/images/groups.svg',
                              color: isSelected4 ? lightColor : Colors.grey,  height: 18),
                        ],
                      ),
                      title: Text(isSelected4 ? S.of(context)!.friends : '',
                          style: TextStyle(
                              fontSize: 10,
                              color: isSelected4
                                  ? lightColor
                                  : Colors.transparent))),
                  BottomNavigationBarItem(
                      icon: (_currentUser?.profileImageUrl == null)
                          ? Icon(FontAwesomeIcons.userAlt,
                              size: 15,
                              color: isSelected5 ? lightColor : Colors.grey)
                          : Container(
                              height: 25,
                              width: 25,
                              child: CircleAvatar(
                                radius: 25.0,
                                backgroundColor: Colors.grey,
                                backgroundImage: CachedNetworkImageProvider(
                                    _currentUser!.profileImageUrl!),
                              ),
                            ),
                      title: Text(isSelected5 ? S.of(context)!.profile : '',
                          style: TextStyle(
                              fontSize: 9,
                              color: isSelected4 ? lightColor : lightColor))),
                ],
                backgroundColor: darkColor,
                selectedItemColor: lightColor,
                showUnselectedLabels: true,
                selectedLabelStyle: TextStyle(fontSize: 12),
                type: BottomNavigationBarType.fixed,
                onTap: onItemClicked,
              ),
              backgroundColor: Colors.transparent,
              body: (_isLoading == true)
                  ? Center(
                      child: SpinKitFadingCircle(color: Colors.white, size: 40),
                    )
                  : TabBarView(
                      // physics: NeverScrollableScrollPhysics(),
                      controller: tabController,
                      children: [
                        FeedsScreen(
                          homeController: homeController,
                          currentUser: _currentUser,
                          goToCameraScreen: _goToCameraScreen,
                        ),
                        MessagesScreen(
                            currentUser: _currentUser,
                            searchFrom: SearchFrom.homeScreen),
                        CallsScreen(currentUser: _currentUser),
                        ContactScreen(
                            currentUser: _currentUser,
                            searchFrom: SearchFrom.homeScreen),
                        ProfileScreen(user: _currentUser),
                      ],
                    )),
        ),
      ],
    );
  }
}
