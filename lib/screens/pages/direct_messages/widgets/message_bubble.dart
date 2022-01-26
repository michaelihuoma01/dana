import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/screens/pages/direct_messages/nested_screens/full_screen_image.dart';
import 'package:Dana/screens/pages/direct_messages/nested_screens/full_screen_video.dart';
import 'package:Dana/services/services.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:Dana/widgets/chat_bubbles.dart';
import 'package:Dana/widgets/common_widgets/heart_anime.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageBubble extends StatefulWidget {
  final Chat? chat;
  final Message? message;
  final AppUser? user;
  final bool? isGroup;

  const MessageBubble({this.chat, this.isGroup, this.message, this.user});

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with WidgetsBindingObserver {
  bool? _isLiked = false;
  bool _heartAnim = false;
  bool showTime = false;
  bool isPlayingMsg = false, isRecording = false, isSending = false;
  String? recordFilePath;
  VideoPlayerController? _controller;
  ChewieController? chewieController;

  Duration duration = new Duration();
  Duration position = new Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLiked = widget.message!.isLiked;
    });
    initVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  initVideo() async {
    try {
      if (widget.message!.videoUrl != null) {
        if (_controller == null) {
          _controller = VideoPlayerController.network(widget.message!.videoUrl!)
            ..initialize().then((_) {
              // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
              setState(() {});
            });
          chewieController = ChewieController(
            videoPlayerController: _controller!,
            autoPlay: false,
            looping: false,
          );
        }
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  _likeUnLikeMessage(String? currentUserId) {
    ChatService.likeUnlikeMessage(widget.message!, widget.chat!.id, !_isLiked!,
        widget.user!, currentUserId);
    setState(() => _isLiked = !_isLiked!);

    if (_isLiked!) {
      setState(() {
        _heartAnim = true;
      });
      Timer(Duration(milliseconds: 350), () {
        setState(() {
          _heartAnim = false;
        });
      });
    }
  }

  void _changeSeek(double value) {
    print("===========================$value");
    setState(() {
      audioPlayer.seek(new Duration(seconds: value.toInt() + 1));
    });
  }

  Future _loadFile(String url) async {
    // final bytes = await readBytes(Uri.parse(url));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');

    // await file.writeAsBytes(bytes);
    if (await file.exists()) {
      setState(() {
        recordFilePath = file.path;
        // isPlayingMsg = true;
        // print(isPlayingMsg);
      });
      await play();
      // setState(() {
      //   isPlayingMsg = true;
      //   print(isPlayingMsg);
      // });
    }
  }

  play() async {
    final url = widget.message!.audioUrl;

    if (url != null) {
      if (isPlayingMsg == false) {
        await audioPlayer.play(url, isLocal: false);
        setState(() {
          // recordFilePath = file.path;
          isPlayingMsg = true;
          print(isPlayingMsg);
        });
      } else {
        await audioPlayer.pause();

        setState(() {
          isPlayingMsg = false;
          print(isPlayingMsg);
        });
      }
    }

    audioPlayer.onDurationChanged.listen((value) {
      setState(() {
        duration = value;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((value) {
      setState(() {
        position = value;
      });
    });
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        isPlayingMsg = false;
        duration = new Duration();
        position = new Duration();
        print(isPlayingMsg);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppUser currentUser =
        Provider.of<UserData>(context, listen: false).currentUser!;

    final bool isMe = widget.message!.senderId == currentUser.id;

    int receiverIndex = widget.chat!.memberInfo!
        .indexWhere((member) => member!.id == widget.message!.senderId);

    _buildText() {
      return GestureDetector(
        onTap: () async {
          // setState(() {
          //   showTime = true;
          // });

          // showModalBottomSheet(
          //     context: context,
          //     backgroundColor: Colors.transparent,
          //     builder: (context) {
          //       return Padding(
          //         padding: const EdgeInsets.all(20),
          //         child: Container(
          //           height: 120,
          //           decoration: BoxDecoration(color: darkColor),
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: <Widget>[
          //               GestureDetector(
          //                 onTap: () async {
          //                   print(widget.message!.id);
          //                   Navigator.pop(context);

          //                   await chatsRef
          //                       .doc(widget.chat!.id)
          //                       .collection('messages')
          //                       .doc(widget.message!.id)
          //                       .delete()
          //                       .then((docs) {
          //                     print('=======succesful');
          //                   });
          //                 },
          //                 child: Padding(
          //                     padding: const EdgeInsets.only(top: 20),
          //                     child: Text('Delete',
          //                         style: TextStyle(
          //                             color: Colors.red,
          //                             fontSize: 16,
          //                             fontWeight: FontWeight.w600))),
          //               ),
          //               GestureDetector(
          //                 onTap: () async {
          //                   print(widget.message!.id);
          //                   Clipboard.setData(
          //                       ClipboardData(text: widget.message!.text));
          //                   Navigator.pop(context);
          //                 },
          //                 child: Padding(
          //                     padding: const EdgeInsets.only(bottom: 20),
          //                     child: Text('Copy',
          //                         style: TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 16,
          //                             fontWeight: FontWeight.w600))),
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     });
        },
        onDoubleTap: widget.message!.senderId == currentUser.id
            ? null
            : () => _likeUnLikeMessage(currentUser.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          child: Container(
            child: Text(
              widget.message!.text!,
              style: TextStyle(
                  color: isMe ? Colors.white : Colors.black, fontSize: 14),
            ),
          ),
        ),
      );
    }

    _buildAudio() {
      return GestureDetector(
        onTap: () {
          setState(() {
            showTime = true;
          });
        },
        onDoubleTap: widget.message!.senderId == currentUser.id
            ? null
            : () => _likeUnLikeMessage(currentUser.id),
        child: Container(
          height: 60,
          child: BubbleNormalAudio(
              // color: Color(0xFFE8E8EE),
              color: isMe ? lightColor : Color(0xFFE8E8EE),
              duration: duration.inSeconds.toDouble(),
              position: position.inSeconds.toDouble(),
              isPlaying: isPlayingMsg,
              isLoading: isSending,
              isPause: !isPlayingMsg,
              onSeekChanged: _changeSeek,
              tail: true,
              onPlayPauseButtonClick: play),
        ),
        //     Padding(
        //       padding: const EdgeInsets.all(5),
        //       child: Row(mainAxisSize: MainAxisSize.min, children: [
        //   GestureDetector(
        //       onTap: () {
        //         print(widget.message.audioUrl);
        //         _loadFile(widget.message.audioUrl);
        //       },
        //       child: Icon(isPlayingMsg ? Icons.pause : Icons.play_arrow,
        //           color: isMe ? Colors.white : Colors.black),
        //   ),
        //   SizedBox(width: 10),
        //   Text('Audio Message',
        //         style: TextStyle(
        //             color: isMe ? Colors.white : Colors.black, fontSize: 14)),
        // ]),
        //     ),
      );
    }

    _buildFile() {
      return GestureDetector(
        onTap: () {
          setState(() {
            showTime = true;
          });
        },
        onDoubleTap: widget.message!.senderId == currentUser.id
            ? null
            : () => _likeUnLikeMessage(currentUser.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          child: GestureDetector(
            onTap: () {
              print(widget.message!.fileUrl);
              launch(widget.message!.fileUrl!);
            },
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(FontAwesomeIcons.fileAlt,
                  color: isMe ? Colors.white : Colors.black),
              SizedBox(width: 10),
              Text('Document',
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.black, fontSize: 14)),
            ]),
          ),
        ),
      );
    }

    _imageFullScreen(url) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImage(url),
          ));
    }

    _videoFullScreen(url) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenVideo(url),
          ));
    }

    _buildVideo(BuildContext context) {
      final size = MediaQuery.of(context).size;
      if (_controller != null) {
        return GestureDetector(
          onLongPress: () {
            setState(() {
              showTime = true;
            });

            showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(color: darkColor),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              print(widget.message!.id);
                              Navigator.pop(context);

                              await chatsRef
                                  .doc(widget.chat!.id)
                                  .collection('messages')
                                  .doc(widget.message!.id)
                                  .delete()
                                  .then((docs) {
                                print('=======succesful');
                              });
                            },
                            child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text('Delete',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600))),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          },
          onDoubleTap: widget.message!.senderId == currentUser.id
              ? null
              : () => _likeUnLikeMessage(currentUser.id),
          // onTap: () => _videoFullScreen(widget.message!.videoUrl),
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Hero(
                      tag: widget.message!.videoUrl!,
                      child: (_controller != null)
                          ? _controller!.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Chewie(controller: chewieController!),
                                )
                              : Row(mainAxisSize: MainAxisSize.min, children: [
                                  Container(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: lightColor)),
                                ])
                          : Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: lightColor))
                            ]),
                    ),
                  ),
                  _heartAnim ? HeartAnime(80.0) : SizedBox.shrink(),
                ],
              )),
        );
      } else {
        initVideo();
      }
    }

    _buildImage(BuildContext context) {
      final size = MediaQuery.of(context).size;
      return GestureDetector(
        onLongPress: () {
          setState(() {
            showTime = true;
          });
          showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(color: darkColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            print(widget.message!.id);
                            Navigator.pop(context);

                            await chatsRef
                                .doc(widget.chat!.id)
                                .collection('messages')
                                .doc(widget.message!.id)
                                .delete()
                                .then((docs) {
                              print('=======succesful');
                            });
                          },
                          child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text('Delete',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600))),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        onDoubleTap: widget.message!.senderId == currentUser.id
            ? null
            : () => _likeUnLikeMessage(currentUser.id),
        onTap: () => _imageFullScreen(widget.message!.imageUrl),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: size.height * 0.4,
              width: size.width * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Hero(
                  tag: widget.message!.imageUrl!,
                  child: CachedNetworkImage(
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return Center(
                        child: CircularProgressIndicator(
                            color: lightColor,
                            value: downloadProgress.progress),
                      );
                    },
                    fadeInDuration: Duration(milliseconds: 500),
                    imageUrl: widget.message!.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            _heartAnim ? HeartAnime(80.0) : SizedBox.shrink(),
          ],
        ),
      );
    }

    _buildGiphy(BuildContext context) {
      final size = MediaQuery.of(context).size;
      return GestureDetector(
        onLongPress: () {
          setState(() {
            showTime = true;
          });
        },
        onDoubleTap: widget.message!.senderId == currentUser.id
            ? null
            : () => _likeUnLikeMessage(currentUser.id),
        onTap: () => _imageFullScreen(widget.message!.giphyUrl),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: size.height * 0.3,
              width: size.width * 0.6,
              decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Hero(
                  tag: widget.message!.giphyUrl!,
                  child: CachedNetworkImage(
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return Center(
                        child: CircularProgressIndicator(
                            color: lightColor,
                            value: downloadProgress.progress),
                      );
                    },
                    fadeInDuration: Duration(milliseconds: 500),
                    imageUrl: widget.message!.giphyUrl!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            _heartAnim ? HeartAnime(80.0) : SizedBox.shrink(),
          ],
        ),
      );
    }

    Padding _buildLikeIcon() {
      return Padding(
        padding: isMe
            ? const EdgeInsets.only(left: 5)
            : const EdgeInsets.only(right: 5),
        child: GestureDetector(
          onTap: widget.message!.senderId == currentUser.id
              ? null
              : () => _likeUnLikeMessage(currentUser.id),
          child: Icon(
            widget.message!.isLiked! ? Icons.favorite : Icons.favorite_border,
            color: widget.message!.isLiked! ? Colors.red : Colors.grey[400],
            size: 15,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              if (!isMe && widget.isGroup!)
                Text(
                  '${widget.chat!.memberInfo![receiverIndex]!.name}',
                  style: TextStyle(fontSize: 12, color: lightColor),
                ),
              if (!isMe && widget.isGroup!) const SizedBox(height: 6.0),
              Row(
                children: [
                  // if (!isMe) _buildLikeIcon(),

//                   Slidable(
//   actionPane: SlidableDrawerActionPane(),
//   actionExtentRatio: 0.25,
//   child: Container(
//     color: Colors.white,
//     child: ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.indigoAccent,
//         child: Text('$3'),
//         foregroundColor: Colors.white,
//       ),
//       title: Text('Tile n°$3'),
//       subtitle: Text('SlidableDrawerDelegate'),
//     ),
//   ),
//   secondaryActions: <Widget>[
//     SlideAction(
//       color: Colors.blue,
//        child: Padding(
//                               padding: isMe
//                                   ? const EdgeInsets.only(right: 0.0)
//                                   : const EdgeInsets.only(left: 0.0),
//                               child: Text(
//                                 '${timeFormat.format(widget.message.timestamp.toDate())}',
//                                 style:
//                                     TextStyle(fontSize: 10, color: Colors.grey),
//                               ),
//                             ) ,
//     ),
//   ],
// ),

                  Dismissible(
                    key: UniqueKey(),
                    direction: isMe
                        ? DismissDirection.endToStart
                        : DismissDirection.startToEnd,
                    dragStartBehavior: DragStartBehavior.start,
                    confirmDismiss: (direction) {
                      print('=======$direction');

                      return showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(color: darkColor),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () async {
                                        print(widget.message!.id);
                                        Navigator.pop(context);

                                        await chatsRef
                                            .doc(widget.chat!.id)
                                            .collection('messages')
                                            .doc(widget.message!.id)
                                            .delete()
                                            .then((docs) {
                                          print('=======succesful');
                                        });
                                      },
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Text('Delete',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        print(widget.message!.id);
                                        Clipboard.setData(ClipboardData(
                                            text: widget.message!.text));
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 20),
                                          child: Text('Copy',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    background: Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Container(
                          color: Colors.transparent,
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: isMe
                                    ? const EdgeInsets.only(right: 0.0)
                                    : const EdgeInsets.only(left: 0.0),
                                child: Text(
                                  '${timeago.format(widget.message!.timestamp!.toDate())}',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ))),
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.80,
                      ),
                      decoration: BoxDecoration(
                        color: widget.message!.text != null ||
                                // widget.message.videoUrl != null ||
                                widget.message!.audioUrl != null ||
                                widget.message!.fileUrl != null
                            ? isMe
                                ? lightColor
                                : Colors.white
                            : Colors.transparent,
                        borderRadius: (isMe)
                            ? BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20))
                            : BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                        // border: Border.all(
                        //     color: widget.message.text != null
                        //         ? isMe
                        //             ? Theme.of(context).primaryColor
                        //             : Theme.of(context).cardColor
                        //         : Colors.transparent),
                      ),
                      child: widget.message!.text != null
                          ? _buildText()
                          : widget.message!.imageUrl != null
                              ? _buildImage(context)
                              : widget.message!.audioUrl != null
                                  ? _buildAudio()
                                  : widget.message!.videoUrl != null
                                      ? _buildVideo(context)
                                      : widget.message!.fileUrl != null
                                          ? _buildFile()
                                          : _buildGiphy(context),
                    ),
                  ),
                  // if (isMe) _buildLikeIcon()
                ],
              ),
              const SizedBox(height: 6.0),
              Visibility(
                visible: showTime,
                child: Padding(
                  padding: isMe
                      ? const EdgeInsets.only(right: 0.0)
                      : const EdgeInsets.only(left: 0.0),
                  child: Text(
                    '${timeFormat.format(widget.message!.timestamp!.toDate())}',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
