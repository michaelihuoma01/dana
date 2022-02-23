import 'package:Dana/utils/constants.dart';
import 'package:camera/camera.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/screens/home.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/show_error_dialog.dart';
import 'package:Dana/widgets/blank_story_circle.dart';
import 'package:Dana/widgets/story_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';

class StoriesWidget extends StatefulWidget {
  final List<AppUser?> users;
  final Function goToCameraScreen;
  const StoriesWidget(this.users, this.goToCameraScreen);

  @override
  _StoriesWidgetState createState() => _StoriesWidgetState();
}

class _StoriesWidgetState extends State<StoriesWidget> {
  bool _isLoading = false;
  List<AppUser?> _followingUsers = [];
  List<Story> _stories = [];
  AppUser? _currentUser;
  bool _isCurrentUserHasStories = false;
  List<CameraDescription>? _cameras;
  CameraConsumer _cameraConsumer = CameraConsumer.story;

  @override
  void initState() {
    super.initState();
    _getStories();
    _getCameras();
  }

  void _backToHomeScreenFromCameraScreen() {
    // _selectPage(1);
    // _pageController.animateToPage(1,
    //     duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                currentUserId: Provider.of<UserData>(context, listen: false)
                    .currentUser!
                    .id)));
  }

  Future<Null> _getCameras() async {
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

  Future<void> _getStories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _currentUser = Provider.of<UserData>(context, listen: false).currentUser;
    });

    if (!mounted) return;

    List<AppUser?> followingUsersWithStories = [];

    List<Story> stories = [];

    List<Story>? currentUserStories = await StoriesService.getStoriesByUserId(
        Provider.of<UserData>(context, listen: false).currentUser!.id, true);

    if (currentUserStories != null) {
      followingUsersWithStories.add(_currentUser);
      stories = currentUserStories;
      if (!mounted) return;
      setState(() => _isCurrentUserHasStories = true);
    }

    for (AppUser? user in widget.users) {
      List<Story>? userStories =
          await StoriesService.getStoriesByUserId(user!.id, true);
      if (!mounted) return;

      if (userStories != null && userStories.isNotEmpty) {
        followingUsersWithStories.add(user);

        for (Story story in userStories) {
          stories.add(story);
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _followingUsers = followingUsersWithStories;
      _stories = stories;
    });

    _cameras = await availableCameras().then((value) {
      print('object $value');
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? Container(
            height: 90,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(left: 5.0),
              scrollDirection: Axis.horizontal,
              itemCount: _isCurrentUserHasStories
                  ? _followingUsers.length
                  : (_followingUsers.length + 1),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0 && !_isCurrentUserHasStories) {
                  return _buildBlankStoryCircle();
                } else if (index > 0 && !_isCurrentUserHasStories) {
                  return _buildStoryCircle(index - 1);
                }
                return _buildStoryCircle(index);
              },
            ))
        : Center(
            child: SpinKitFadingCircle(color: lightColor, size: 30),
          );
  }

  BlankStoryCircle _buildBlankStoryCircle() {
    return BlankStoryCircle(
      goToCameraScreen: widget.goToCameraScreen,
      user: _currentUser,
      cameras: _cameras,
      cameraConsumer: _cameraConsumer,
      backToHomeScreenFromCameraScreen: _backToHomeScreenFromCameraScreen,
    );
  }

  StoryCircle _buildStoryCircle(int index) {
    AppUser? user = _followingUsers[index];
    List<Story> userStories =
        _stories.where((Story story) => story.authorId == user!.id).toList();

    return StoryCircle(
      currentUserId: _currentUser!.id,
      user: user,
      userStories: userStories,
      size: 60,
    );
  }
}
