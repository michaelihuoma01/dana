import 'dart:io';

import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/post_model.dart';
import 'package:Dana/models/user_data.dart';
import 'package:Dana/screens/pages/camera_screen/widgets/post_caption_form.dart';
import 'package:Dana/services/api/database_service.dart';
import 'package:Dana/services/api/storage_service.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/custom_navigation.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CreatePostScreen extends StatefulWidget {
  final Post? post;
  final PostStatus? postStatus;
  final File? imageFile;
  final Function? backToHomeScreen;

  CreatePostScreen(
      {this.post, this.postStatus, this.imageFile, this.backToHomeScreen});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  TextEditingController _captionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? _caption = '';
  bool _isLoading = false;
  bool isVideo = false, isPublic = false;
  Post? _post;
  String? _currentUserId;

  @override
  initState() {
    super.initState();

    String? currentUserId =
        Provider.of<UserData>(context, listen: false).currentUser!.id;

    setState(() {
      _currentUserId = currentUserId;
    });
    if (widget.post != null) {
      setState(() {
        _captionController.value =
            TextEditingValue(text: widget.post!.caption!);

        _caption = widget.post!.caption;

        _post = widget.post;
      });
    }

    if (widget.imageFile != null) {
      String? mimeStr = lookupMimeType(widget.imageFile!.path)!;
      var fileType = mimeStr.split('/');
      print('file type $fileType');

      if (fileType.first.contains('image')) {
        isVideo = false;
        print('post is a video $isVideo');
      } else {
        isVideo = true;
        print('post is a video $isVideo');
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() async {
    FocusScope.of(context).unfocus();

    if (!_isLoading &&
        _formKey.currentState!.validate() &&
        (widget.imageFile != null || _post!.imageUrl != null)) {
      _formKey.currentState!.save();

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      if (_post != null) {
        // Edit existing Post
        Post post = Post(
          id: _post!.id,
          imageUrl: _post!.imageUrl,
          videoUrl: _post!.videoUrl,
          caption: _captionController.text.trim(),
          location: (_post!.location == 'true') ? "true" : "false",
          likeCount: _post!.likeCount,
          commentCount: _post!.commentCount,
          authorId: _post!.authorId,
          timestamp: _post!.timestamp,
          commentsAllowed: _post!.commentsAllowed,
        );

        DatabaseService.editPost(post, widget.postStatus);
      } else {
        //Create new Post
        try {
          if (isVideo == false) {
            String imageUrl =
                (await StroageService.uploadPost(widget.imageFile!));

            print(imageUrl);
            Post post = Post(
                imageUrl: imageUrl,
                caption: _captionController.text,
                location: (isPublic == true) ? "true" : "false",
                likeCount: 0,
                commentCount: 0,
                videoUrl: null,
                authorId: _currentUserId,
                timestamp: Timestamp.fromDate(DateTime.now()),
                commentsAllowed: true);

            if (isPublic == true) {
              DatabaseService.createPublicPost(post);
            } else {
              DatabaseService.createPost(post);
            }
          } else {
            print(widget.imageFile);
            String videoUrl =
                (await StroageService.uploadPostVideo(widget.imageFile!));

            print('======================== $videoUrl');

            Post post = Post(
                imageUrl: null,
                caption: _captionController.text,
                location: (isPublic == true) ? "true" : "false",
                likeCount: 0,
                commentCount: 0,
                videoUrl: videoUrl,
                authorId: _currentUserId,
                timestamp: Timestamp.fromDate(DateTime.now()),
                commentsAllowed: true);

            if (isPublic == true) {
              DatabaseService.createPublicPost(post);
            } else {
              DatabaseService.createPost(post);
            }
          }
        } catch (e) {
          print('/////////========///////////$e');
        }
      }

      if (widget.post == null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(currentUserId: _currentUserId)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(currentUserId: widget.post!.authorId)));
      }
    }
  }

  // void _goToHomeScreen() {
  //   print(_currentUserId);
  //   CustomNavigation.navigateToHomeScreen(context, _currentUserId);
  // }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    AppUser? currentUser =
        Provider.of<UserData>(context, listen: false).currentUser;
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
          currentUser: currentUser,
          scaffold: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                backgroundColor: darkColor,
                brightness: Brightness.dark,
                iconTheme: IconThemeData(color: Colors.white),
                centerTitle: true,
                title: Text(
                    widget.imageFile == null
                        ? 'Edit Post'
                        : S.of(context)!.newpost,
                    style: TextStyle(color: Colors.white)),
                actions: <Widget>[
                  !_isLoading
                      ? FlatButton(
                          onPressed: _submit,
                          child: Text(
                            widget.imageFile == null
                                ? 'Save'
                                : S.of(context)!.share,
                            style: TextStyle(
                                color: lightColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ))
                      : Padding(
                          padding: const EdgeInsets.only(right: 10.0, left: 10),
                          child: Center(
                            child: SizedBox(
                              child:
                                  CircularProgressIndicator(color: lightColor),
                              width: 20,
                              height: 20,
                            ),
                          ),
                        )
                ],
              ),
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      PostCaptionForm(
                        screenSize: screenSize,
                        imageUrl: _post?.imageUrl,
                        controller: _captionController,
                        imageFile: widget.imageFile,
                        isVideo: isVideo,
                        onChanged: (val) {
                          setState(() {
                            _caption = val;
                          });
                        },
                      ),
                      Theme(
                          data: ThemeData(unselectedWidgetColor: lightColor),
                          child: CheckboxListTile(
                              value: isPublic,
                              checkColor: darkColor,
                              activeColor: lightColor,
                              selectedTileColor: lightColor,
                              title: Text('Share to public',
                                  maxLines: 3,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
                              onChanged: (value) {
                                if (isPublic == false) {
                                  setState(() {
                                    isPublic = true;
                                  });
                                } else {
                                  setState(() {
                                    isPublic = false;
                                  });
                                }
                              })),
                    ],
                  ),
                ),
              )),
        ),
      ],
    );
  }
}
