import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/files.dart';
import 'package:video_player/video_player.dart';

class PostCaptionForm extends StatefulWidget {
  final File? imageFile;
  final String? imageUrl;
  final TextEditingController controller;
  final Size screenSize;
  final Function onChanged;
  final bool isVideo;

  PostCaptionForm({
    required this.imageFile,
    required this.imageUrl,
    required this.controller,
    required this.screenSize,
    required this.onChanged,
    required this.isVideo,
  });
  @override
  _PostCaptionFormState createState() => _PostCaptionFormState();
}

class _PostCaptionFormState extends State<PostCaptionForm> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.file(widget.imageFile!)
      ..initialize().then((_) {
        // print('succesful folks');
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 15.0),
            height: 45.0,
            width: 45.0,
            child: (widget.isVideo != true)
                ? AspectRatio(
                    aspectRatio: 487 / 451,
                    child: Container(
                        decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.topCenter,
                        image: (widget.imageFile == null
                            ? CachedNetworkImageProvider(
                                widget.imageUrl.toString())
                            : FileImage(widget.imageFile!)) as ImageProvider<Object>,
                      ),
                    )),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Hero(
                      tag: widget.imageFile!,
                      child: _controller.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            )
                          : CircularProgressIndicator(color: lightColor),
                    ),
                  )),
        Container(
          width: widget.screenSize.width - 92,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextFormField(
              onChanged: (value) => widget.onChanged(value),
              maxLength: 150,
              controller: widget.controller,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: 'Write a caption...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none),
            ),
          ),
        ),
      ],
    );
  }
}
