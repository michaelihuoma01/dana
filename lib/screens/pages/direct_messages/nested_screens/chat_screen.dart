import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:Dana/screens/pages/direct_messages/nested_screens/chat_camera_screen.dart';
import 'package:auto_direction/auto_direction.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/calls/call_utilities.dart';
import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/chat_model.dart';
import 'package:Dana/models/message_model.dart';
import 'package:Dana/models/user_data.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/pages/direct_messages/widgets/message_bubble.dart';
import 'package:Dana/screens/pages/group_info.dart';
import 'package:Dana/screens/pages/outgoing_audiocall.dart';
import 'package:Dana/services/api/chat_service.dart';
import 'package:Dana/services/api/storage_service.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utilities/custom_navigation.dart';
import 'package:Dana/utilities/themes.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:Dana/widgets/dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:record/record.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  final AppUser? receiverUser;
  final File? imageFile;
  final List<dynamic>? userIds, groupMembers;
  final bool? isGroup;
  final String? groupName, admin;
  final Chat? chat;

  const ChatScreen(
      {this.receiverUser,
      this.isGroup,
      this.groupName,
      this.admin,
      this.groupMembers,
      this.userIds,
      this.chat,
      this.imageFile});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isComposingMessage = false;
  Chat? _chat;
  bool _isChatExist = false;
  AppUser? _currentUser;
  List<dynamic>? _userIds = [];
  List<AppUser>? _memberInfo = [];
  bool _isLoading = false;
  List<AppUser?> groupMembers = [];
  bool isPlayingMsg = false, isRecording = false, isSending = false;
  String? recordFilePath;
  var cameras;
  bool isRemoved = false;
  bool _mRecorderIsInited = false;
  // FlutterSoundRecorder? _myRecorder;
  Record? recordPlugin;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    // _myRecorder!.closeAudioSession();

    super.dispose();
  }

  _setup() async {
    setState(() => _isLoading = true);
    // _myRecorder = new FlutterSoundRecorder();
    // _myRecorder!.setSubscriptionDuration(Duration(seconds: 1));

    // _myRecorder!.openAudioSession().then((value) {
    //   setState(() {
    //     _mRecorderIsInited = true;
    //   });
    // });
    recordPlugin = new Record();

    cameras = await availableCameras();

    AppUser currentUser =
        Provider.of<UserData>(context, listen: false).currentUser!;

    List<String?> userIds = [];
    if (widget.isGroup!) {
      widget.chat!.memberInfo!.forEach((element) {
        userIds.add(element!.id);
      });
      // userIds.add(currentUser.id);

    } else {
      userIds.add(currentUser.id);
      userIds.add(widget.receiverUser!.id);
    }

    List<AppUser>? users = [];
    if (widget.isGroup!) {
      widget.chat!.memberInfo!.forEach((element) {
        users.add(element!);
      });
    } else {
      users.add(currentUser);
      users.add(widget.receiverUser!);
    }

    Chat? chat = await ChatService.getChatByUsers(userIds);

    bool isChatExist = chat != null;

    if (widget.groupMembers != null) {
      for (AppUser? user in widget.groupMembers!) {
        groupMembers.add(user);
      }
    }

//     String finalStr = groupMembers.reduce((value, element) {
//   return value.n + element;
// });

    if (isChatExist) {
      ChatService.setChatRead(context, chat, true);

      Chat chatWithMemberInfo = Chat(
        id: chat.id,
        memberIds: chat.memberIds,
        memberInfo: users,
        groupName: widget.groupName,
        admin: widget.admin,
        readStatus: chat.readStatus,
        recentMessage: chat.recentMessage,
        recentSender: chat.recentSender,
        recentTimestamp: chat.recentTimestamp,
      );

      setState(() {
        _chat = chatWithMemberInfo;
      });
      print(_chat!.id);
    } else {
      if (widget.isGroup == true) {
        setState(() {
          _chat = widget.chat;
        });
        print(_chat!.id);
      }
    }

    setState(() {
      _currentUser = currentUser;
      _isChatExist = (widget.isGroup == true) ? true : isChatExist;
      _memberInfo = users;
      _userIds = userIds;
      _isLoading = false;
    });

    checkForImage();
  }

  uploadAudio() {
    final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
        'audio/messages/${_currentUser!.id}/audio${DateTime.now().millisecondsSinceEpoch.toString()}.aac');

    UploadTask task = firebaseStorageRef.putFile(File(recordFilePath!));
    task.then((value) async {
      var audioURL = await value.ref.getDownloadURL();
      String strVal = audioURL.toString();

      await _sendMessage(
          text: null,
          imageUrl: null,
          giphyUrl: null,
          audioUrl: strVal,
          videoUrl: null,
          fileName: null,
          fileUrl: null);
    }).catchError((e) {
      print(e);
    });
  }

  int i = 0;

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    print(sdPath);
    return sdPath + "/test_${i++}.aac";
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  // void startRecord() async {
  //   bool hasPermission = await checkPermission();
  //   if (hasPermission) {
  //     recordFilePath = await getFilePath();

  // RecordMp3.instance.start(recordFilePath!, (type) {
  //   setState(() {});
  // });
  //   } else {}
  // }

  Future<void> startRecord() async {
    recordFilePath = await getFilePath();

    // await _myRecorder!.startRecorder(toFile: recordFilePath);
    await recordPlugin!.start(
        path: recordFilePath, // required
        encoder: AudioEncoder.AAC // by default
        );
  }

  Future<void> stopRecord() async {
    recordPlugin!.stop();

    // await _myRecorder!.stopRecorder();
    setState(() {
      isSending = true;
    });
    await uploadAudio();

    setState(() {
      isPlayingMsg = false;
    });
  }

  // void stopRecord() async {
  // bool s = RecordMp3.instance.stop();
  // if (s) {
  //   setState(() {
  //     isSending = true;
  //   });
  //   await uploadAudio();

  //   setState(() {
  //     isPlayingMsg = false;
  //   });
  // }
  // }

  checkForImage() {
    if (widget.imageFile != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) => SimpleDialog(
                backgroundColor:
                    Theme.of(context).backgroundColor.withOpacity(0.8),
                title: Container(
                  child: Column(
                    children: [
                      Text(
                        'Send Image To ${widget.receiverUser!.name}?',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Image.file(
                        widget.imageFile!,
                        height: 300,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SimpleDialogOption(
                        child: Center(
                          child: Text('Send',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              )),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);

                          String imageUrl =
                              await StroageService.uploadMessageImage(
                                  widget.imageFile!);
                          _sendMessage(
                              text: null,
                              imageUrl: imageUrl,
                              giphyUrl: null,
                              audioUrl: null,
                              videoUrl: null,
                              fileName: null,
                              fileUrl: null);
                        },
                      ),
                      SimpleDialogOption(
                        child: Center(
                          child: Text('Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              )),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ));
    }
  }

  Future<void> _createChat(userIds) async {
    Chat chat = await ChatService.createChat(_memberInfo!, userIds, context);

    setState(() {
      _chat = chat;
      _isChatExist = true;
    });
  }

  Container _buildMessageTF() {
    return (isRemoved)
        ? Container(
            child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text('You cannot send message',
                    style: TextStyle(color: Colors.white))),
          ))
        : Container(
            child: Column(
              children: [
                BrandDivider(),
                isSending
                    ? LinearProgressIndicator(
                        backgroundColor: Colors.grey[100],
                        valueColor: AlwaysStoppedAnimation<Color>(lightColor),
                      )
                    : SizedBox(),
                Row(
                  children: <Widget>[
                    Row(
                      children: [
                        GestureDetector(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child:
                                  Icon(Icons.add, color: lightColor, size: 28),
                            ),
                            onTap: () async {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      color: darkColor,
                                      height: 120,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () async {
                                              Navigator.pop(context);

                                              List<Media>? res =
                                                  await (ImagesPicker.pick(
                                                language: Language.English,
                                                count: 5,
                                                pickType: PickType.image,
                                                gif: true,
                                                cropOpt: CropOption(
                                                  aspectRatio:
                                                      CropAspectRatio.custom,
                                                  cropType: CropType
                                                      .rect, // currently for android
                                                ),
                                              ));
                                              setState(() => isSending = true);

                                              res?.forEach((element) async {
                                                File imageFile =
                                                    File(element.path);

                                                if (imageFile != null) {
                                                  String imageUrl =
                                                      await StroageService
                                                          .uploadMessageImage(
                                                              imageFile);
                                                  _sendMessage(
                                                      text: null,
                                                      imageUrl: imageUrl,
                                                      giphyUrl: null,
                                                      audioUrl: null,
                                                      videoUrl: null,
                                                      fileName: null,
                                                      fileUrl: null);
                                                }
                                              });

                                              setState(() => isSending = false);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: Column(children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: lightColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: isRecording
                                                                  ? Colors.white
                                                                      .withOpacity(
                                                                          0.4)
                                                                  : Colors
                                                                      .transparent,
                                                              spreadRadius: 12)
                                                        ]),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Icon(Icons.photo)),
                                                SizedBox(height: 5),
                                                Text('Photos',
                                                    style: TextStyle(
                                                        color: Colors.white))
                                              ]),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              Navigator.pop(context);

                                              var pickedFile =
                                                  await (ImagePicker()
                                                      .pickVideo(
                                                source: ImageSource.gallery,
                                              ));
                                              File imageFile =
                                                  File(pickedFile!.path);
                                              setState(() => isSending = true);

                                              if (imageFile != null) {
                                                String videoUrl =
                                                    await StroageService
                                                        .uploadMessageVideo(
                                                            imageFile);

                                                _sendMessage(
                                                    text: null,
                                                    imageUrl: null,
                                                    giphyUrl: null,
                                                    audioUrl: null,
                                                    videoUrl: videoUrl,
                                                    fileName: null,
                                                    fileUrl: null);
                                              }
                                              setState(() => isSending = false);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: Column(children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: lightColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: isRecording
                                                                  ? Colors.white
                                                                      .withOpacity(
                                                                          0.4)
                                                                  : Colors
                                                                      .transparent,
                                                              spreadRadius: 9)
                                                        ]),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: new Icon(
                                                        Icons.videocam)),
                                                SizedBox(height: 5),
                                                new Text('Videos',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ]),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              Navigator.pop(context);

                                              FilePickerResult? result =
                                                  await FilePicker.platform
                                                      .pickFiles();

                                              if (result != null) {
                                                Uint8List? fileBytes =
                                                    result.files.first.bytes;
                                                String fileName =
                                                    result.files.first.name;

                                                String mimeStr = lookupMimeType(
                                                    result.paths.first!)!;
                                                var fileType =
                                                    mimeStr.split('/');
                                                print(
                                                    'file type ${result.files.first.size}');
                                                print(
                                                    'file type ${result.files.first.extension}');
                                                setState(
                                                    () => isSending = true);

                                                String fileUrl =
                                                    await StroageService
                                                        .uploadMessageFile(
                                                            File(result.files
                                                                .first.path!),
                                                            result.files.first
                                                                .extension);
                                                String fileNamePath =
                                                    result.files.first.name;
                                                _sendMessage(
                                                    text: null,
                                                    imageUrl: null,
                                                    giphyUrl: null,
                                                    audioUrl: null,
                                                    videoUrl: null,
                                                    fileName: fileNamePath,
                                                    fileUrl: fileUrl);
                                              }
                                              setState(() => isSending = false);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: lightColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: isRecording
                                                                  ? Colors.white
                                                                      .withOpacity(
                                                                          0.4)
                                                                  : Colors
                                                                      .transparent,
                                                              spreadRadius: 9)
                                                        ]),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    child: new Icon(
                                                        FontAwesomeIcons.file,
                                                        size: 20),
                                                  ),
                                                  SizedBox(height: 5),
                                                  new Text('Documents',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            }),
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(Icons.insert_emoticon,
                                color: lightColor, size: 22),
                          ),
                          onTap: () async {
                            GiphyGif? gif = await GiphyGet.getGif(
                              context: context,
                              apiKey:
                                  '', //YOUR API KEY HERE
                              lang: GiphyLanguage.spanish,
                            );
                            if (gif != null && mounted) {
                              _sendMessage(
                                  text: null,
                                  imageUrl: null,
                                  giphyUrl: gif.images!.original!.url,
                                  audioUrl: null,
                                  videoUrl: null,
                                  fileName: null,
                                  fileUrl: null);
                            }
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: AutoDirection(
                        text: _messageController.text,
                        child: TextField(
                          minLines: 1,
                          maxLines: 3,
                          style: TextStyle(color: Colors.white),
                          cursorColor: lightColor,
                          controller: _messageController,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (messageText) {
                            setState(() =>
                                _isComposingMessage = messageText.isNotEmpty);
                          },
                          decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                              hintText: S.of(context)!.entermsg),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: GestureDetector(
                          onTap: () async {
                            var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChatCameraScreen(cameras: cameras)));

                            File imageFile = File(result);
                            String mimeStr = lookupMimeType(result)!;
                            var fileType = mimeStr.split('/');

                            setState(() => isSending = true);

                            if (fileType.first.contains('image')) {
                              print('file type is image');
                              String imageUrl =
                                  await StroageService.uploadMessageImage(
                                      imageFile);
                              _sendMessage(
                                  text: null,
                                  imageUrl: imageUrl,
                                  giphyUrl: null,
                                  audioUrl: null,
                                  videoUrl: null,
                                  fileName: null,
                                  fileUrl: null);
                            } else {
                              print('file type is video');
                              String videoUrl =
                                  await StroageService.uploadMessageVideo(
                                      imageFile);
                              _sendMessage(
                                  text: null,
                                  imageUrl: null,
                                  audioUrl: null,
                                  giphyUrl: null,
                                  videoUrl: videoUrl,
                                  fileName: null,
                                  fileUrl: null);
                              setState(() => isSending = false);
                            }
                          },
                          child: Icon(Icons.camera_alt_outlined,
                              color: lightColor, size: 22)),
                    ),
                    SizedBox(width: 10),
                    if (!_isComposingMessage)
                      GestureDetector(
                        onLongPress: () {
                          print('start recording');

                          startRecord();
                          setState(() {
                            isRecording = true;
                          });
                        },
                        onLongPressEnd: (details) {
                          print('end recording');

                          stopRecord();
                          setState(() {
                            isRecording = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: lightColor,
                                boxShadow: [
                                  BoxShadow(
                                      color: isRecording
                                          ? lightColor.withOpacity(0.8)
                                          : Colors.transparent,
                                      spreadRadius: 10)
                                ]),
                            padding: isRecording
                                ? EdgeInsets.all(15)
                                : EdgeInsets.all(5),
                            // width: 30.0,
                            child: Icon(Icons.mic_outlined,
                                color: darkColor, size: 18),
                          ),
                        ),
                      ),
                    if (_isComposingMessage)
                      GestureDetector(
                        onTap: _isComposingMessage && !isSending
                            ? () => _sendMessage(
                                text: _messageController.text.trim(),
                                imageUrl: null,
                                giphyUrl: null,
                                audioUrl: null,
                                videoUrl: null,
                                fileName: null,
                                fileUrl: null)
                            : null,
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
              ],
            ),
          );
  }

  _sendMessage(
      {String? text,
      String? imageUrl,
      String? giphyUrl,
      String? audioUrl,
      String? videoUrl,
      String? fileUrl,
      String? fileName}) async {
    if ((text != null && text.trim().isNotEmpty) ||
        (fileName != null && fileName.trim().isNotEmpty) ||
        imageUrl != null ||
        audioUrl != null ||
        videoUrl != null ||
        fileUrl != null ||
        giphyUrl != null) {
      setState(() => isSending = true);

      if (!_isChatExist) {
        await _createChat(_userIds);
      }

      if (imageUrl == null &&
          giphyUrl == null &&
          audioUrl == null &&
          videoUrl == null &&
          fileUrl == null) {
        _messageController.clear();
        setState(() => _isComposingMessage = false);
      }

      Message message = Message(
        senderId: _currentUser!.id,
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

      ChatService.sendChatMessage(
          _chat!, message, widget.receiverUser!, context, widget.isGroup!);
      chatsRef
          .doc(_chat!.id)
          .update({'readStatus.${widget.receiverUser!.id}': false});
      setState(() => isSending = false);
    }
  }

  _buildMessagesStream() {
    return StreamBuilder(
      stream: (widget.isGroup!)
          ? chatsRef
              .doc(_chat!.id)
              .collection('groupMessages')
              .orderBy('timestamp', descending: true)
              .limit(20)
              .snapshots()
          : chatsRef
              .doc(_chat!.id)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(20)
              .snapshots(),
      builder: (BuildContext contex, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        return Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              physics: AlwaysScrollableScrollPhysics(),
              reverse: true,
              cacheExtent: 1000,
              children: _buildMessageBubbles(
                  snapshot as AsyncSnapshot<QuerySnapshot<Object>>),
            ),
          ),
        );
      },
    );
  }

  List<MessageBubble> _buildMessageBubbles(
    AsyncSnapshot<QuerySnapshot> messages,
  ) {
    List<MessageBubble> messageBubbles = [];

    messages.data!.docs.forEach((doc) {
      Message message = Message.fromDoc(doc);

      MessageBubble messageBubble = MessageBubble(
        user: message.senderId == _currentUser!.id
            ? _currentUser
            : widget.receiverUser,
        chat: _chat,
        message: message,
        isGroup: widget.isGroup,
      );
      messageBubbles.removeWhere((msgBbl) => message.id == msgBbl.message!.id);
      messageBubbles.add(messageBubble);
    });
    return messageBubbles;
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
        WillPopScope(
          onWillPop: () {
            if (_chat != null) {
              ChatService.setChatRead(context, _chat!, true);
            }

            return Future.value(true);
          },
          child: PickupLayout(
            currentUser: _currentUser,
            scaffold: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.white),
                brightness: Brightness.dark,
                backgroundColor: darkColor,
                actions: (widget.isGroup == true)
                    ? []
                    : [
                        GestureDetector(
                            onTap: () async {
                              try {
                                CallUtils.dial(
                                    from: _currentUser!,
                                    to: widget.receiverUser!,
                                    context: context,
                                    isAudio: false);
                              } catch (e) {
                                print('=============$e');
                              }
                            },
                            child: Icon(FontAwesomeIcons.video, size: 18)),
                        SizedBox(width: 20),
                        GestureDetector(
                            onTap: () async {
                              try {
                                CallUtils.dial(
                                    from: _currentUser!,
                                    to: widget.receiverUser!,
                                    context: context,
                                    isAudio: true);
                              } catch (e) {
                                print('=============$e');
                              }
                            },
                            child: Icon(FontAwesomeIcons.phoneAlt, size: 18)),
                        SizedBox(width: 20),
                      ],
                title: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        (widget.isGroup == true)
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GroupInfo(
                                      currentUser: _currentUser,
                                      groupUsers: groupMembers,
                                      groupUserIds: widget.userIds,
                                      admin: widget.admin,
                                      chatID: _chat!.id,
                                      groupName: widget.groupName),
                                ),
                              )
                            : CustomNavigation.navigateToUserProfile(
                                context: context,
                                appUser: widget.receiverUser,
                                userId: widget.receiverUser!.id,
                                currentUserId: _currentUser!.id,
                                isCameFromBottomNavigation: false,
                              );
                      },
                      child: (widget.isGroup == true)
                          ? CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.grey,
                              backgroundImage: (widget.chat!.groupUrl! == '')
                                  ? AssetImage(placeHolderImageRef)
                                  : CachedNetworkImageProvider(
                                          widget.chat!.groupUrl!)
                                      as ImageProvider<Object>?,
                            )
                          : CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.grey,
                              backgroundImage: (widget
                                      .receiverUser!.profileImageUrl!.isEmpty)
                                  ? AssetImage(placeHolderImageRef)
                                  : CachedNetworkImageProvider(
                                          widget.receiverUser!.profileImageUrl!)
                                      as ImageProvider<Object>?,
                            ),
                    ),
                    SizedBox(width: 15.0),
                    GestureDetector(
                        onTap: () async {
                          print(_chat!.id);
                          if (widget.isGroup!) {
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GroupInfo(
                                    currentUser: _currentUser,
                                    groupUsers: groupMembers,
                                    groupUserIds: widget.userIds,
                                    admin: widget.admin,
                                    chatID: _chat!.id,
                                    groupName: widget.groupName),
                              ),
                            );
                            print('============$result');
                            if (result == 'isRemoved') {
                              setState(() {
                                isRemoved = true;
                              });
                            }
                          } else {
                            CustomNavigation.navigateToUserProfile(
                              context: context,
                              userId: widget.receiverUser!.id,
                              currentUserId: _currentUser!.id,
                              isCameFromBottomNavigation: false,
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                (widget.isGroup == true)
                                    ? widget.groupName!
                                    : widget.receiverUser!.name!,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(height: 3),
                            Text(
                                widget.isGroup!
                                    ? '${groupMembers.map((e) => e!.name).join(', ')}'
                                    : (widget.receiverUser!.status == 'online')
                                        ? 'Online'
                                        : '${S.of(context)!.lastseen} ${timeago.format(widget.receiverUser!.lastSeenOnline!.toDate())}',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 11))
                          ],
                        )),
                  ],
                ),
              ),
              body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (_isChatExist && !_isLoading) _buildMessagesStream(),
                    if (!_isChatExist && _isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (!_isChatExist && !_isLoading) SizedBox.shrink(),
                    _buildMessageTF(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
