import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/generated/l10n.dart';
import 'package:dana/models/models.dart';
import 'package:dana/models/user_data.dart';
import 'package:dana/models/user_model.dart';
import 'package:dana/screens/home.dart';
import 'package:dana/screens/pages/camera_screen/widgets/location_form.dart';
import 'package:dana/screens/pages/post_audience.dart';
import 'package:dana/services/api/auth_service.dart';
import 'package:dana/services/api/database_service.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utilities/custom_navigation.dart';
import 'package:dana/utilities/show_error_dialog.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/utils/utility.dart';
import 'package:dana/widgets/add_post_appbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AddPost extends StatefulWidget {
  String? currentUserId;
  // final int initialPage;
  List<CameraDescription>? cameras;
  AddPost({this.currentUserId, this.cameras});

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  AppUser? _currentUser;
  List<CameraDescription>? _cameras; 
  CameraConsumer _cameraConsumer = CameraConsumer.post;

  TextEditingController _captionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  String _caption = '';
  String? _currentUserId;
  Post? _post;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getCurrentUser();
    _getCameras();

    String? currentUserId =
        Provider.of<UserData>(context, listen: false).currentUser!.id;

    setState(() {
      _currentUserId = currentUserId;
    });

    setState(() {
      // _captionController.value = TextEditingValue(text: _post.caption);
      // _locationController.value = TextEditingValue(text: _post.location);
      // _caption = _post.caption;
    });
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

  void _getCurrentUser() async {
    AppUser currentUser =
        await DatabaseService.getUserWithId(widget.currentUserId);
    Provider.of<UserData>(context, listen: false).currentUser = currentUser;

    print('i have the current user now');
    setState(() => _currentUser = currentUser);
    AuthService.updateTokenWithUser(currentUser);
  }

  void _backToHomeScreenFromCameraScreen() {
    // _selectPage(1);
    // _pageController.animateToPage(1,
    //     duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomeScreen(currentUserId: widget.currentUserId)));
  }

  void _submit() async {
    FocusScope.of(context).unfocus();

    if (!_isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      // if (_post != null) {
      //   // Edit existing Post
      //   Post post = Post(
      //     id: _post.id,
      //     imageUrl: _post.imageUrl,
      //     caption: _captionController.text.trim(),
      //     location: _locationController.text.trim(),
      //     likeCount: _post.likeCount,
      //     authorId: _post.authorId,
      //     timestamp: _post.timestamp,
      //     commentsAllowed: _post.commentsAllowed,
      //   );

      //   DatabaseService.editPost(post, widget.postStatus);
      // } else {
      //Create new Post
      // String imageUrl = (await StroageService.uploadPost(widget.imageFile));
      Post post = Post(
        // imageUrl: imageUrl,
        caption: _captionController.text.trim(),
        likeCount: 0,
        commentCount: 0,
        authorId: _currentUserId,
        timestamp: Timestamp.fromDate(DateTime.now()),
        commentsAllowed: true,
      );

      DatabaseService.createPost(post);
    }
    _goToHomeScreen();
  }
  // }

  void _goToHomeScreen() {
    CustomNavigation.navigateToHomeScreen(context, _currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    // Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: darkColor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AddPostAppbar(
            isTab: false,
            title:  S.of(context)!.cam,
            isPost: true,
            backToHomeScreenFromCameraScreen: _backToHomeScreenFromCameraScreen,
            cameras: _cameras,
            cameraConsumer: _cameraConsumer,
            bgColor:
                (_caption != '') ? lightColor : lightColor.withOpacity(0.5),
            onTap: (_caption != '')
                ? () {
                    _submit(); 
                  }
                : null,
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: TextStyle(color: Colors.white, fontSize: 18),
                maxLines: null,
                controller: _captionController,
                onChanged: (value) {
                  setState(() {
                    _caption = value;
                  });
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide.none),
                  hintText:  S.of(context)!.happening,
                  focusedBorder:
                      UnderlineInputBorder(borderSide: BorderSide.none),
                  enabledBorder:
                      UnderlineInputBorder(borderSide: BorderSide.none),
                  hintStyle: TextStyle(color: Colors.grey),
                  // prefixIcon: Padding(
                  //     padding: const EdgeInsets.only(right: 20),
                  //     child: GestureDetector(
                  //         onTap: () {
                  //           Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (context) => PostAudience()));
                  //         },
                  //         child: Icon(Icons.public, color: lightColor))),
                ),
                cursorColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
