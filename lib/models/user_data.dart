import 'package:Dana/calls/call.dart';
import 'package:Dana/models/chat_model.dart';
import 'package:Dana/models/post_model.dart';
import 'package:Dana/models/story_model.dart';
import 'package:Dana/models/user_model.dart';
import 'package:flutter/cupertino.dart';

class UserData extends ChangeNotifier {
  String? currentUserId;

  // String profileImageUrl;

  List<AppUser?> friends = [];
  List<Post?> feeds = [];
  List<Call?> call = [];
  List<Story?> story = [];
  List<Chat?> chat = [];
  AppUser? currentUser;
}
