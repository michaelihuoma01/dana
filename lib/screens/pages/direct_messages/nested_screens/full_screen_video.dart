import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideo extends StatefulWidget {
  final String videoUrl;

  FullScreenVideo(this.videoUrl);

  @override
  _FullScreenVideoState createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  VideoPlayerController _controller;

  ChewieController chewieController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });

    chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: darkColor,
        iconTheme: IconThemeData(color: Colors.white),
        brightness: Brightness.dark,
        elevation: 0,
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.file_download))
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Container(
              color: darkColor,
              child: Center(
                child: Hero(
                  tag: widget.videoUrl,
                  child: _controller.value.isInitialized
                      ? Chewie(controller: chewieController)
                      : CircularProgressIndicator(color: lightColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
