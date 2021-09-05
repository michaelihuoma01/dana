import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dana/screens/pages/camera_screen/nested_screens/create_post_screen.dart';
import 'package:dana/screens/pages/camera_screen/nested_screens/create_story_screen.dart';
import 'package:dana/screens/pages/camera_screen/nested_screens/edit_photo_screen.dart';
import 'package:dana/screens/pages/stories_screen/widgets/circular_icon_button.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utilities/themes.dart';
import 'package:dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropping/constant/enums.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart' as A;
import 'package:ionicons/ionicons.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraConsumer cameraConsumer;
  final Function backToHomeScreen;
  CameraScreen(this.cameras, this.backToHomeScreen, this.cameraConsumer);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  String imagePath;
  bool _toggleCamera = false;
  CameraController controller;
  final _picker = ImagePicker();
  CameraConsumer _cameraConsumer = CameraConsumer.post;
  bool fromCamera = false;
  bool isRecording = false;
  File imgFile;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    try {
      onCameraSelected(widget.cameras[0]);
    } catch (e) {
      print(e.toString());
    }
    if (widget.cameraConsumer != CameraConsumer.post) {
      changeConsumer(widget.cameraConsumer);
    }
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      print('NOne found');
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No Camera Found',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      return Container();
    }
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Transform.scale(
              scale: 1.3,
              child: new CameraPreview(controller),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: CircularIconButton(
                splashColor: kBlueColorWithOpacity,
                icon: Icon(
                  Ionicons.close_sharp,
                  color: Colors.white,
                  size: 22,
                ),
                onTap: widget.backToHomeScreen,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              topLeft: Radius.circular(15))),
                      onPressed: () => changeConsumer(CameraConsumer.post),
                      color: _cameraConsumer == CameraConsumer.post
                          ? Colors.white.withOpacity(0.85)
                          : Colors.black38,
                      child: Text(
                        'Post',
                        style: TextStyle(
                          fontSize: 18,
                          color: _cameraConsumer == CameraConsumer.post
                              ? Colors.black
                              : Colors.white,
                          fontWeight: _cameraConsumer == CameraConsumer.post
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(15),
                              topRight: Radius.circular(15))),
                      onPressed: () => changeConsumer(CameraConsumer.story),
                      color: _cameraConsumer == CameraConsumer.story
                          ? Colors.white.withOpacity(0.85)
                          : Colors.black38,
                      child: Text(
                        'Story',
                        style: TextStyle(
                          fontSize: 18,
                          color: _cameraConsumer == CameraConsumer.story
                              ? Colors.black
                              : Colors.white,
                          fontWeight: _cameraConsumer == CameraConsumer.story
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 140.0,
                  padding: EdgeInsets.all(15.0),
                  color: Colors.black45,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Material(
                          color: Colors.transparent,
                          child: GestureDetector(
                            onTap: () {
                              _captureImage();
                            },
                            onLongPress: () {
                              print('start recording');

                              startRecording();
                            },
                            onLongPressEnd: (details) {
                              print('end recording');

                              _captureVideo();
                            },
                            child: Column(
                              children: [
                                Text('Tap for photo & hold to record',
                                    style: TextStyle(color: Colors.white)),
                                SizedBox(height: 5),
                                Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: isRecording
                                                  ? Colors.red.withOpacity(0.6)
                                                  : Colors.transparent,
                                              spreadRadius: 3)
                                        ]),
                                    padding: EdgeInsets.all(4.0),
                                    // child: Image.asset(
                                    //     'assets/images/shutter.png',
                                    //     width: 68,
                                    //     height: 68),
                                    child: Icon(
                                      Icons.circle_outlined,
                                      color: isRecording
                                          ? Colors.red
                                          : Colors.white,
                                      size: 80,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0)),
                            onTap: () {
                              if (!_toggleCamera) {
                                onCameraSelected(widget.cameras[1]);
                                setState(() {
                                  _toggleCamera = true;
                                });
                              } else {
                                onCameraSelected(widget.cameras[0]);
                                setState(() {
                                  _toggleCamera = false;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(4.0),
                              child: Image.asset(
                                'assets/images/switch_camera.png',
                                color: Colors.grey[200],
                                width: 42.0,
                                height: 42.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0)),
                            onTap: getGalleryImage,
                            child: Container(
                              padding: EdgeInsets.all(4.0),
                              child: Image.asset(
                                'assets/images/gallery_button.png',
                                color: Colors.grey[200],
                                width: 42.0,
                                height: 42.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void changeConsumer(CameraConsumer cameraConsumer) {
    if (_cameraConsumer != cameraConsumer) {
      setState(() => _cameraConsumer = cameraConsumer);
    }
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    // if (controller != null)
    controller = CameraController(cameraDescription, ResolutionPreset.ultraHigh,
        enableAudio: true, imageFormatGroup: ImageFormatGroup.bgra8888);

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showMessage('Camera Error: ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      showException(e);
    }

    if (mounted) setState(() {});
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  void _captureImage() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) {
          showMessage('Picture saved to $filePath');
          fromCamera = true;
          setCameraResult();
        }
      }
    });
  }

  void _captureVideo() {
    stopRecording().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) {
          showMessage('Picture saved to $filePath');
          fromCamera = true;
          setCameraResult();
        }
      }
    });
  }

  void getGalleryImage() async {
    var pickedFile =
        await A.ImagesPicker.pick(pickType: A.PickType.all, count: 1);
    // .getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print(
          '//-/-/-/-/-/-/-/-/-//-/-/-/-/-/-/-/-/-/-||||||||${pickedFile.first.path}');

      setState(() {
        imagePath = pickedFile.first.path;
      });
      fromCamera = false;

      if (_cameraConsumer == CameraConsumer.post) {
        String mimeStr = lookupMimeType(imagePath);
        var fileType = mimeStr.split('/');
        print('file type $fileType');

        if (fileType.first.contains('video')) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CreatePostScreen(
                      imageFile: imgFile,
                    )),
          );
          print('===========ITS a video');
        } else {
          final ByteData bytes = await rootBundle.load(pickedFile.first.path);
          final Uint8List list = bytes.buffer.asUint8List();

          // var croppedImage;
          // ImageCropping.cropImage(
          //   context,
          //   list,
          //   () {
          //     CircularProgressIndicator(color: lightColor);
          //   },
          //   () {
          //     // hideLoader();
          //     print('done============');
          //   },
          //   (data) {
          //     setState(
          //       () {
          //     print('done///////////////');

          //         pickedFile.first.path = data;
          //         croppedImage = data;
          //       },
          //     );
          //   },
          //   selectedImageRatio: ImageRatio.RATIO_1_1,
          //   visibleOtherAspectRatios: true,
          //   squareBorderWidth: 2,
          //   squareCircleColor: Colors.black,
          //   defaultTextColor: lightColor,
          //   selectedTextColor: Colors.black,
          //   colorForWhiteSpace: Colors.white,
          // );

          var croppedImage = await ImageCropper.cropImage(
            androidUiSettings: AndroidUiSettings(
              backgroundColor: Theme.of(context).backgroundColor,
              toolbarColor: Theme.of(context).appBarTheme.color,
              toolbarWidgetColor: Theme.of(context).accentColor,
              toolbarTitle: 'Crop Photo',
              activeControlsWidgetColor: Colors.blue,
            ),
            sourcePath: pickedFile.first.path,
            aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EditPhotoScreen(
                      imageFile: croppedImage,
                    )
                //  CreatePostScreen(
                //   imageFile: croppedImage,
                // ),
                ),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateStoryScreen(File(imagePath)),
          ),
        );
      }
    } else {
      print('No image selected.');
    }
  }

  void setCameraResult() async {
    if (_cameraConsumer == CameraConsumer.post) {
      var croppedImage = await _cropImage(XFile(imagePath));

      if (croppedImage == null) {
        return;
      }

      String mimeStr = lookupMimeType(imagePath);
      var fileType = mimeStr.split('/');
      print('file type $fileType');

      if (fileType.first.contains('video')) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CreatePostScreen(
                    imageFile: imgFile,
                  )),
        );
        print('===========ITS a video');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EditPhotoScreen(
                    imageFile: croppedImage,
                  )
              //  CreatePostScreen(
              //   imageFile: croppedImage,
              // ),
              ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateStoryScreen(File(imagePath)),
        ),
      );
    }
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showMessage('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Dana/Images';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture().then((value) {
        GallerySaver.saveImage(value.path);
      });
    } on CameraException catch (e) {
      showException(e);
      return null;
    }
    return filePath;
  }

  startRecording() async {
    if (!controller.value.isInitialized) {
      showMessage('Error: select a camera first.');
      return null;
    }

    try {
      controller.startVideoRecording();
      setState(() {
        isRecording = true;
      });
    } on CameraException catch (e) {
      showException(e);
      return null;
    }
  }

  Future<String> stopRecording() async {
    if (!controller.value.isInitialized) {
      showMessage('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Dana/Videos';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      controller.stopVideoRecording().then((value) {
        setState(() {
          isRecording = false;
        });
        imgFile = File(value.path);
        GallerySaver.saveVideo(value.path);
      });
    } on CameraException catch (e) {
      showException(e);
      return null;
    }
    return filePath;
  }

  _cropImage(XFile imageFile) async {
    if (fromCamera == true) {
      String mimeStr = lookupMimeType(imageFile.path);
      var fileType = mimeStr.split('/');
      print('file type $fileType');

      if (fileType.first.contains('image')) {
        imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

        var croppedImage = await ImageCropper.cropImage(
          androidUiSettings: AndroidUiSettings(
            backgroundColor: Theme.of(context).backgroundColor,
            toolbarColor: Theme.of(context).appBarTheme.color,
            toolbarWidgetColor: Theme.of(context).accentColor,
            toolbarTitle: 'Crop Photo',
            activeControlsWidgetColor: Colors.blue,
          ),
          sourcePath: imageFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        );

// final ByteData bytes = await rootBundle.load(imageFile.path);
//           final Uint8List list = bytes.buffer.asUint8List();

          // var croppedImage;
          // ImageCropping.cropImage(
          //   context,
          //   list,
          //   () {
          //     CircularProgressIndicator(color: lightColor);
          //   },
          //   () {
          //     // hideLoader();
          //     print('done============');
          //   },
          //   (data) {
          //     setState(
          //       () {
          //         // imageFile.path = data;
          //         croppedImage = data;
          //       },
          //     );
          //   },
          //   selectedImageRatio: ImageRatio.RATIO_1_1,
          //   visibleOtherAspectRatios: true,
          //   squareBorderWidth: 2,
          //   squareCircleColor: Colors.black,
          //   defaultTextColor: lightColor,
          //   selectedTextColor: Colors.black,
          //   colorForWhiteSpace: Colors.white,
          // );
        return croppedImage;
      } else {
        imageFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
        return imageFile;
      }
    }
  }

  void showException(CameraException e) {
    logError(e.code, e.description);
    print('Error: ${e.code}\n${e.description}');
  }

  void showMessage(String message) {
    print(message);
  }

  void logError(String code, String message) =>
      print('Error: $code\nMessage: $message');
}
