import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:dana/models/chat_model.dart';
import 'package:dana/models/user_data.dart';
import 'package:dana/models/user_model.dart';
import 'package:dana/screens/auth/login.dart';
import 'package:dana/screens/auth/register.dart';
import 'package:dana/screens/pages/camera_screen/camera_screen.dart';
import 'package:dana/screens/tabs/calls_screen.dart';
import 'package:dana/screens/tabs/contacts_screen.dart';
import 'package:dana/screens/tabs/feeds_screen.dart';
import 'package:dana/screens/tabs/messages_screen.dart';
import 'package:dana/screens/tabs/profile_screen.dart';
import 'package:dana/services/api/auth_service.dart';
import 'package:dana/services/api/database_service.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utilities/show_error_dialog.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/utils/shared_preferences_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'HomeScreen';

  // final AppUser currentUser;
  final String currentUserId;
  final int initialPage;
  final List<CameraDescription> cameras;
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
  PageController _pageController;
  AppUser _currentUser;
  List<CameraDescription> _cameras;
  CameraConsumer _cameraConsumer = CameraConsumer.post;
  final ScrollController homeController = ScrollController();
  bool isRead = true;
  bool isSeen = true;

  AppUser user;
  TabController tabController;
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
  bool isRequest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _getCurrentUser();
    _getCameras();
    checkUnreadMessages();
    _setupFriends();
    // _initPageView();
    _listenToNotifications();
    AuthService.updateToken();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(() {
      onItemClicked(tabController.index);
    });

    print('============//////////////=====$isRead');
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //TODO: set status to online here in firestore
      DatabaseService.updateStatusOnline(widget.currentUserId);
      print('==============USER ONLINE');
    } else {
      //TODO: set status to offline here in firestore
      print('==============USER OFFLINE');

      DatabaseService.updateStatusOffline(widget.currentUserId);
    }
  }

  _setupFriends() async {
    print('skipping current user');

    QuerySnapshot usersSnapshot = await usersRef.get();

    for (var userDoc in usersSnapshot.docs) {
      AppUser user = AppUser.fromDoc(userDoc);

      isFollower = await DatabaseService.isUserFollower(
        currentUserId: widget.currentUserId,
        userId: user.id,
      );

      isFollowingUser = await DatabaseService.isFollowingUser(
        currentUserId: widget.currentUserId,
        userId: user.id,
      );

      if (widget.currentUserId == user.id) {
        print('skipping current user');
      } else {
        if (isFollower == true && isFollowingUser == true) {
          isFriends = true;
          _friends.add(user);
             setState(() {
            isSeen = true;
          });

          print('friends ${user.name} $isFriends');
        } else if (isFollower == true && isFollowingUser != true) {
          isRequest = true;
          _requests.add(user);
          setState(() {
            isSeen = false;
          });

          print('not friends ${user.name} $isFriends');
        } else if (isFollower != true && isFollowingUser == true) {
          isRequest = false;
          isFriends = false;
          setState(() {
            isSeen = false;
          });
        }
      }
    }
    print(_friends.length);
    setState(() {
      _isLoading = false;
    });
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

  void _listenToNotifications() async {
    FirebaseMessaging.onMessage.listen((message) {
      print('On message: $message');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('On messageOpenedApp: $message');
    });

    FirebaseMessaging.onBackgroundMessage((message) {
      print('On onBackgroundMessage: $message');
      return Future<void>.value();
    });
    if (Platform.isIOS) {
      print('Initializing notifications');

      _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await [Permission.camera, Permission.microphone].request();
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
    print('i have the current user now  ');

    // String userId = await SharedPreferencesUtil.getUserId();

    AppUser currentUser =
        await DatabaseService.getUserWithId(widget.currentUserId);

    Provider.of<UserData>(context, listen: false).currentUser = currentUser;
    if (currentUser == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    // print('i have the current user now $userId ');
    setState(() => _currentUser = currentUser);
    // AuthService.updateTokenWithUser(currentUser);
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
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController..index = selectedIndex;
      print(selectedIndex);

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
                            color: isSelected1 ? lightColor : Colors.grey),
                      ),
                      title: Text(isSelected1 ? 'Feeds' : '',
                          style: TextStyle(
                              fontSize: 10,
                              color: isSelected1
                                  ? lightColor
                                  : Colors.transparent))),
                  BottomNavigationBarItem(
                      icon: Stack(
                        children: [
                          SvgPicture.asset('assets/images/message.svg',
                              color: isSelected2 ? lightColor : Colors.grey),
                          if (isRead == false)
                            Positioned(
                                left: 11,
                                child: Icon(Icons.circle,
                                    color: Colors.red, size: 12))
                        ],
                      ),
                      title: Text(isSelected2 ? 'Messages' : '',
                          style: TextStyle(
                              fontSize: 10,
                              color: isSelected2
                                  ? lightColor
                                  : Colors.transparent))),
                  BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/images/call.svg',
                          color: isSelected3 ? lightColor : Colors.grey),
                      title: Text(isSelected3 ? 'Calls' : '',
                          style: TextStyle(
                              fontSize: 10,
                              color: isSelected3
                                  ? lightColor
                                  : Colors.transparent))),
                  BottomNavigationBarItem(
                      icon: Stack(
                        children: [
                          SvgPicture.asset('assets/images/groups.svg',
                              color: isSelected4 ? lightColor : Colors.grey),
                          if (isSeen == false)
                            Positioned(
                                left: 11,
                                child: Icon(Icons.circle,
                                    color: Colors.red, size: 12))
                        ],
                      ),
                      title: Text(isSelected4 ? 'Friends' : '',
                          style: TextStyle(
                              fontSize: 10,
                              color: isSelected4
                                  ? lightColor
                                  : Colors.transparent))),
                  BottomNavigationBarItem(
                      icon: (_currentUser?.profileImageUrl == null)
                          ? Icon(FontAwesomeIcons.userAlt,
                              size: 17,
                              color: isSelected5 ? lightColor : Colors.grey)
                          : Container(
                              height: 28,
                              width: 28,
                              child: CircleAvatar(
                                radius: 25.0,
                                backgroundColor: Colors.grey,
                                backgroundImage: CachedNetworkImageProvider(
                                    _currentUser?.profileImageUrl),
                              ),
                            ),
                      title: Text(isSelected5 ? 'Profile' : '',
                          style: TextStyle(
                              fontSize: 9,
                              color: isSelected4
                                  ? lightColor
                                  : Colors.transparent))),
                ],
                backgroundColor: darkColor,
                selectedItemColor: lightColor,
                showUnselectedLabels: true,
                selectedLabelStyle: TextStyle(fontSize: 12),
                type: BottomNavigationBarType.fixed,
                onTap: onItemClicked,
              ),
              backgroundColor: Colors.transparent,
              body: TabBarView(
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
