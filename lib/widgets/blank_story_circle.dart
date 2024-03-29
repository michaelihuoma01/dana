import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/screens/pages/camera_screen/camera_screen.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlankStoryCircle extends StatelessWidget {
  final AppUser? user;
  final Function goToCameraScreen;
  final double size;
  final List<CameraDescription>? cameras;

  final bool showUserName;

  var backToHomeScreenFromCameraScreen, cameraConsumer;

  BlankStoryCircle(
      {required this.user,
      required this.goToCameraScreen,
      this.size = 55,
      this.cameras,
      this.backToHomeScreenFromCameraScreen,
      this.cameraConsumer,
      this.showUserName = true});
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserData>(context).currentUser!;
    bool isCurrentUser = currentUser.id == user!.id ? true : false;
    return Container(
      width: size + 20,
      margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                margin: EdgeInsets.all(5.0),
                height: size,
                width: size,
                padding: const EdgeInsets.all(2),
                decoration: isCurrentUser
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 2, color: Colors.grey),
                      )
                    : null,
                child: GestureDetector(
                  onTap: () {
                    if (isCurrentUser) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CameraScreen(
                                  cameras,
                                  backToHomeScreenFromCameraScreen,
                                  cameraConsumer)));
                    }
                  },
                  child: ClipOval(
                    child: Image(
                      image: (user!.profileImageUrl!.isEmpty
                          ? AssetImage(placeHolderImageRef)
                          : CachedNetworkImageProvider(user!.profileImageUrl!)) as ImageProvider<Object>,
                      height: 60.0,
                      width: 60.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (isCurrentUser)
                Positioned(
                  bottom: 5,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: darkColor,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_circle,
                        color: lightColor,
                        size: size == 55 ? 21 : 30,
                      ),
                    ),
                  ),
                )
            ],
          ),
          if (showUserName)
            Expanded(
              child: Text(
                user!.name!,
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                style: TextStyle(color: Colors.white),
              ),
            )
        ],
      ),
    );
  }
}
