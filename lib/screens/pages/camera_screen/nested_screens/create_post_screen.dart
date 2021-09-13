import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/models/post_model.dart';
import 'package:dana/models/user_data.dart';
import 'package:dana/screens/pages/camera_screen/widgets/location_form.dart';
import 'package:dana/screens/pages/camera_screen/widgets/post_caption_form.dart';
import 'package:dana/services/api/database_service.dart';
import 'package:dana/services/api/storage_service.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utilities/custom_navigation.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CreatePostScreen extends StatefulWidget {
  final Post post;
  final PostStatus postStatus;
  final File imageFile;
  final Function backToHomeScreen;

  CreatePostScreen(
      {this.post, this.postStatus, this.imageFile, this.backToHomeScreen});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  TextEditingController _captionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String _caption = '';
  bool _isLoading = false;
  bool isVideo = false;
  Post _post;
  String _currentUserId;

  @override
  initState() {
    super.initState();

    String currentUserId =
        Provider.of<UserData>(context, listen: false).currentUserId;

    setState(() {
      _currentUserId = currentUserId;
    });
    if (widget.post != null) {
      setState(() {
        _captionController.value = TextEditingValue(text: widget.post.caption);
        _locationController.value =
            TextEditingValue(text: widget.post.location);
        _caption = widget.post.caption;

        _post = widget.post;
      });
    }

    if (widget.imageFile != null) {
      String mimeStr = lookupMimeType(widget.imageFile?.path);
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
    _captionController?.dispose();
    _locationController?.dispose();
    super.dispose();
  }

  void _submit() async {
    FocusScope.of(context).unfocus();

    if (!_isLoading &&
        _formKey.currentState.validate() &&
        (widget.imageFile != null || _post.imageUrl != null)) {
      _formKey.currentState.save();

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      if (_post != null) {
        // Edit existing Post
        Post post = Post(
          id: _post.id,
          imageUrl: _post.imageUrl,
          videoUrl: _post.videoUrl,
          caption: _captionController.text.trim(),
          location: _locationController.text.trim(),
          likeCount: _post.likeCount,
          commentCount: _post.commentCount,
          authorId: _post.authorId,
          timestamp: _post.timestamp,
          commentsAllowed: _post.commentsAllowed,
        );

        DatabaseService.editPost(post, widget.postStatus);
      } else {
        //Create new Post
        if (isVideo == false) {
          String imageUrl = (await StroageService.uploadPost(widget.imageFile));

          print(imageUrl);
          Post post = Post(
              imageUrl: imageUrl,
              caption: _captionController.text,
              location: _locationController.text,
              likeCount: 0,
              commentCount: 0,
              videoUrl: null,
              authorId: _currentUserId,
              timestamp: Timestamp.fromDate(DateTime.now()),
              commentsAllowed: true);

          DatabaseService.createPost(post);
        } else {
          print(widget.imageFile);
          String videoUrl =
              (await StroageService.uploadPostVideo(widget.imageFile));

          print('======================== $videoUrl');

          Post post = Post(
              imageUrl: null,
              caption: _captionController.text,
              location: _locationController.text,
              likeCount: 0,
              commentCount: 0,
              videoUrl: videoUrl,
              authorId: _currentUserId,
              timestamp: Timestamp.fromDate(DateTime.now()),
              commentsAllowed: true);

          DatabaseService.createPost(post);
        }
      }
      widget.backToHomeScreen();
    }
  }

  // void _goToHomeScreen() {
  //   print(_currentUserId);
  //   CustomNavigation.navigateToHomeScreen(context, _currentUserId);
  // }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
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
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: darkColor,
              brightness: Brightness.dark,
              iconTheme: IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Text(widget.imageFile == null ? 'Edit Post' : 'New Post',
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                !_isLoading
                    ? FlatButton(
                        onPressed: _caption.trim().length > 3 ? _submit : null,
                        child: Text(
                          widget.imageFile == null ? 'Save' : 'Share',
                          style: TextStyle(
                              color: _caption.trim().length > 3
                                  ? lightColor
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0),
                        ))
                    : Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Center(
                          child: SizedBox(
                            child: CircularProgressIndicator(color: lightColor),
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
                      imageFile: widget?.imageFile,
                      isVideo: isVideo,
                      onChanged: (val) {
                        setState(() {
                          _caption = val;
                        });
                      },
                    ),
                    Divider(color: Colors.white),
                    LocationForm(
                      screenSize: screenSize,
                      controller: _locationController,
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
