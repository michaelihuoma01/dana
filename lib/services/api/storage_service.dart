import 'dart:io';

import 'package:dana/utilities/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class StroageService {
  static Future<String> uploadUserProfileImage(
      String url, File imageFile) async {
    String photoId = Uuid().v4();

    if (url.isNotEmpty) {
      //Updating user profile image
      RegExp exp = RegExp(r'userProfile_(.*).jpg');
      photoId = exp.firstMatch(url)[1];
    }
    File image = await compressImage(photoId, imageFile);
    UploadTask uploadTask = storageRef
        .child('images/users/userProfile_$photoId.jpg')
        .putFile(image);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<File> compressImage(String photoId, File image) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    File compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$photoId.jpg',
      quality: 70,
    );
    return compressedImageFile;
  }

  static Future<String> _uploadImage(
      String path, String imageId, File image) async {
    UploadTask uploadTask = storageRef.child(path).putFile(image);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();

    return downloadUrl;
  }

  static Future<String> uploadPostVideo(File imageFile) async {
    String imageId = Uuid().v4();

    // await VideoCompress.setLogLevel(0);
    // MediaInfo mediaInfo = await VideoCompress.compressVideo(
    //   imageFile.path,
    //   quality: VideoQuality.LowQuality,
    //   includeAudio: true,
    //   deleteOrigin: false, // It's false by default
    // );

    UploadTask uploadTask = storageRef
        .child('videos/posts/post_video$imageId.mp4')
        .putFile(imageFile, SettableMetadata(contentType: 'video/mp4'));
    String downloadUrl = await (await uploadTask)
        .ref
        .getDownloadURL()
        .whenComplete(() => print('successful'));

    return downloadUrl;
  }

  static Future<String> uploadPost(File imageFile) async {
    String photoId = Uuid().v4();
    File image = await compressImage(photoId, imageFile);
    UploadTask uploadTask =
        storageRef.child('images/posts/post_$photoId.jpg').putFile(image);
    // TaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<String> uploadMessageImage(File imageFile) async {
    String imageId = Uuid().v4();
    File image = await compressImage(imageId, imageFile);

    String downloadUrl = await _uploadImage(
      'images/messages/message_$imageId.jpg',
      imageId,
      image,
    );
    return downloadUrl;
  }

  static Future<String> uploadStoryImage(File imageFile) async {
    String imageId = Uuid().v4();
    File image = await compressImage(imageId, imageFile);

    String downloadUrl = await _uploadImage(
      'images/stories/story_$imageId.jpg',
      imageId,
      image,
    );
    return downloadUrl;
  }

  static Future<String> uploadMessageVideo(File imageFile) async {
    String imageId = Uuid().v4();

    // await VideoCompress.setLogLevel(0);
    // MediaInfo mediaInfo = await VideoCompress.compressVideo(
    //   imageFile.path,
    //   quality: VideoQuality.LowQuality,
    //   includeAudio: true,
    //   deleteOrigin: false, // It's false by default
    // );

    UploadTask uploadTask = storageRef
        .child('videos/messages/message_video$imageId.mp4')
        .putFile(imageFile, SettableMetadata(contentType: 'video/mp4'));
    String downloadUrl = await (await uploadTask)
        .ref
        .getDownloadURL()
        .whenComplete(() => print('successful'));

    return downloadUrl;
  }

  static Future<String> uploadMessageFile(File imageFile, String ext) async {
    String imageId = Uuid().v4();

    UploadTask uploadTask = storageRef
        .child('files/messages/message_files$imageId.$ext')
        .putFile(imageFile);
    String downloadUrl = await (await uploadTask)
        .ref
        .getDownloadURL()
        .whenComplete(() => print('successful'));

    return downloadUrl;
  }
}
