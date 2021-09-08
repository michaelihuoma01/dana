import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/models/activity_model.dart';
import 'package:dana/models/post_model.dart';
import 'package:dana/models/user_model.dart';
import 'package:dana/utilities/constants.dart';
import 'package:flutter/services.dart';

class DatabaseService {
  static void updateUser(AppUser user) {
    usersRef.doc(user.id).update({
      'name': user.name,
      'profileImageUrl': user.profileImageUrl,
      'bio': user.bio,
      'pin': user.pin,
      'dob': user.dob,
      'gender': user.gender
    });
  }

  static void updateStatusOnline(String userID) {
    usersRef.doc(userID).update({
      'lastSeenOnline': DateTime.now(),
      'status': 'online',
    });
  }

  static void updateStatusOffline(String userID) {
    usersRef.doc(userID).update({
      'lastSeenOffline': DateTime.now(),
      'status': 'offline',
    });
  }

  static Future<QuerySnapshot> searchUsers(String name) {
    Future<QuerySnapshot> users;
    try {
      users = usersRef
          // .where('name', isGreaterThanOrEqualTo: name)
          .where('pin', isEqualTo: name)
          .get();
    } on FirebaseException catch (e) {
      print(e);
    }
    return users;
  }

  static void createPost(Post post) {
    try {
      postsRef.doc(post.authorId).collection('userPosts').add({
        'imageUrl': post.imageUrl,
        'videoUrl': post.videoUrl,
        'caption': post.caption,
        'likeCount': post.likeCount,
        'commentCount': post.commentCount,
        'authorId': post.authorId,
        'location': post.location,
        'commentsAllowed': post.commentsAllowed,
        'timestamp': post.timestamp
      });
    } catch (e) {
      print(e);
    }
  }

  static void editPost(
    Post post,
    PostStatus postStatus,
  ) {
    String collection;
    if (postStatus == PostStatus.archivedPost) {
      collection = 'archivedPosts';
    } else if (postStatus == PostStatus.feedPost) {
      collection = 'userPosts';
    } else {
      collection = 'deletedPosts';
    }

    postsRef.doc(post.authorId).collection(collection).doc(post.id).update({
      'caption': post.caption,
      'location': post.location,
    });
  }

  static void allowDisAllowPostComments(Post post, bool commentsAllowed) {
    try {
      postsRef.doc(post.authorId).collection('userPosts').doc(post.id).update({
        'commentsAllowed': commentsAllowed,
      });
    } catch (e) {
      print(e);
    }
  }

  static void deletePost(Post post, PostStatus postStatus) {
    postsRef.doc(post.authorId).collection('deletedPosts').doc(post.id).set({
      'imageUrl': post.imageUrl,
      'caption': post.caption,
      'likeCount': post.likeCount,
      'commentCount': post.commentCount,
      'authorId': post.authorId,
      'location': post.location,
      'timestamp': post.timestamp
    });
    String collection;
    postStatus == PostStatus.feedPost
        ? collection = 'userPosts'
        : collection = 'archivedPosts';
    postsRef.doc(post.authorId).collection(collection).doc(post.id).delete();
  }

  static void archivePost(Post post, PostStatus postStatus) {
    postsRef.doc(post.authorId).collection('archivedPosts').doc(post.id).set({
      'imageUrl': post.imageUrl,
      'caption': post.caption,
      'likeCount': post.likeCount,
      'commentCount': post.commentCount,
      'authorId': post.authorId,
      'location': post.location,
      'timestamp': post.timestamp
    });
    String collection;
    postStatus == PostStatus.feedPost
        ? collection = 'userPosts'
        : collection = 'deletedPosts';

    postsRef.doc(post.authorId).collection(collection).doc(post.id).delete();
  }

  static void recreatePost(Post post, PostStatus postStatus) {
    try {
      postsRef.doc(post.authorId).collection('userPosts').doc(post.id).set({
        'imageUrl': post.imageUrl,
        'caption': post.caption,
        'likeCount': post.likeCount,
        'commentCount': post.commentCount,
        'authorId': post.authorId,
        'location': post.location,
        'commentsAllowed': post.commentsAllowed,
        'timestamp': post.timestamp
      });

      String collection;
      postStatus == PostStatus.archivedPost
          ? collection = 'archivedPosts'
          : collection = 'deletedPosts';

      postsRef.doc(post.authorId).collection(collection).doc(post.id).delete();
    } catch (e) {
      print(e);
    }
  }

  static void followUser(
      {String currentUserId, String userId, String receiverToken}) {
    // Add user to current user's following collection
    followingRef
        .doc(currentUserId)
        .collection(userFollowing)
        .doc(userId)
        .set({'timestamp': Timestamp.fromDate(DateTime.now())});

    // Add current user to user's followers collection
    followersRef
        .doc(userId)
        .collection(usersFollowers)
        .doc(currentUserId)
        .set({'timestamp': Timestamp.fromDate(DateTime.now())});

    Post post = Post(
      authorId: userId,
    );

    addActivityItem(
      comment: null,
      currentUserId: currentUserId,
      isFollowEvent: true,
      post: post,
      isCommentEvent: false,
      isLikeEvent: false,
      isLikeMessageEvent: false,
      isMessageEvent: false,
      recieverToken: receiverToken,
    );
  }

  static void unfollowUser({String currentUserId, String userId}) {
    // Remove user from current user's following collection
    followingRef
        .doc(currentUserId)
        .collection(userFollowing)
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // Remove current user from user's followers collection
    followersRef
        .doc(userId)
        .collection(usersFollowers)
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    Post post = Post(
      authorId: userId,
    );

    deleteActivityItem(
      comment: null,
      currentUserId: currentUserId,
      isFollowEvent: true,
      post: post,
      isCommentEvent: false,
      isLikeEvent: false,
      isLikeMessageEvent: false,
      isMessageEvent: false,
    );
  }

  static Future<bool> isFollowingUser(
      {String currentUserId, String userId}) async {
    DocumentSnapshot followingDoc = await followersRef
        .doc(userId)
        .collection(usersFollowers)
        .doc(currentUserId)
        .get();

    return followingDoc.exists;
  }

  static Future<bool> isUserFollower(
      {String currentUserId, String userId}) async {
    DocumentSnapshot followingDoc = await followingRef
        .doc(userId)
        .collection(userFollowing)
        .doc(currentUserId)
        .get();

    return followingDoc.exists;
  }

  static Future<int> numFollowing(String userId) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection(userFollowing).get();
    return followingSnapshot.docs.length;
  }

  static Future<int> numFollowers(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection(usersFollowers).get();

    return followersSnapshot.docs.length;
  }

  static Future<List<String>> getUserFollowingIds(String userId) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection(userFollowing).get();

    List<String> following =
        followingSnapshot.docs.map((doc) => doc.id).toList();
    return following;
  }

  static Future<List<AppUser>> getUserFollowingUsers(String userId) async {
    List<String> followingUserIds = await getUserFollowingIds(userId);
    List<AppUser> followingUsers = [];

    for (var userId in followingUserIds) {
      DocumentSnapshot userSnapshot = await usersRef.doc(userId).get();
      AppUser user = AppUser.fromDoc(userSnapshot);
      followingUsers.add(user);
    }

    return followingUsers;
  }

  static Future<List<String>> getUserFollowersIds(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection(usersFollowers).get();

    List<String> followers =
        followersSnapshot.docs.map((doc) => doc.id).toList();
    return followers;
  }

  static Future<List<Post>> getFeedPosts(String userId) async {
    QuerySnapshot feedSnapshot = await feedsRef
        .doc(userId)
        .collection('userFeed')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts =
        feedSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<List<Post>> getAllFeedPosts() async {
    List<Post> allPosts = [];

    QuerySnapshot usersSnapshot = await usersRef.get();

    for (var userDoc in usersSnapshot.docs) {
      QuerySnapshot feedSnapshot = await postsRef
          .doc(userDoc.id)
          .collection('userPosts')
          .orderBy('timestamp', descending: true)
          .get();

      for (var postDoc in feedSnapshot.docs) {
        Post post = Post.fromDoc(postDoc);
        allPosts.add(post);
      }
    }
    return allPosts;
  }

  static Future<List<Post>> getDeletedPosts(
      String userId, PostStatus postStatus) async {
    String collection;
    postStatus == PostStatus.archivedPost
        ? collection = 'archivedPosts'
        : collection = 'deletedPosts';

    QuerySnapshot feedSnapshot = await postsRef
        .doc(userId)
        .collection(collection)
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts =
        feedSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<List<Post>> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnapshot = await postsRef
        .doc(userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts =
        userPostsSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<AppUser> getUserWithId(String userId) async {
    DocumentSnapshot userDocSnapshot = await usersRef.doc(userId).get();
    if (userDocSnapshot.exists) {
      return AppUser.fromDoc(userDocSnapshot);
    }
    return AppUser();
  }

  static void likePost(
      {String currentUserId, Post post, String receiverToken}) {
    DocumentReference postRef =
        postsRef.doc(post.authorId).collection('userPosts').doc(post.id);
    postRef.get().then((doc) {
      int likeCount = doc['likeCount'];
      postRef.update({'likeCount': likeCount + 1});
      likesRef.doc(post.id).collection('postLikes').doc(currentUserId).set({});
    });

    addActivityItem(
      currentUserId: currentUserId,
      post: post,
      comment: post.caption ?? null,
      isFollowEvent: false,
      isLikeMessageEvent: false,
      isLikeEvent: true,
      isCommentEvent: false,
      isMessageEvent: false,
      recieverToken: receiverToken,
    );
  }

  static void unlikePost({String currentUserId, Post post}) {
    DocumentReference postRef =
        postsRef.doc(post.authorId).collection('userPosts').doc(post.id);
    postRef.get().then((doc) {
      int likeCount = doc['likeCount'];
      postRef.update({'likeCount': likeCount + -1});
      likesRef
          .doc(post.id)
          .collection('postLikes')
          .doc(currentUserId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });

    deleteActivityItem(
      comment: null,
      currentUserId: currentUserId,
      isFollowEvent: false,
      post: post,
      isCommentEvent: false,
      isLikeMessageEvent: false,
      isLikeEvent: true,
      isMessageEvent: false,
    );
  }

  static Future<bool> didLikePost({String currentUserId, Post post}) async {
    DocumentSnapshot userDoc = await likesRef
        .doc(post.id)
        .collection('postLikes')
        .doc(currentUserId)
        .get();
    return userDoc.exists;
  }

  static void commentOnPost(
      {String currentUserId, Post post, String comment, String recieverToken}) {
    commentsRef.doc(post.id).collection('postComments').add({
      'content': comment,
      'authorId': currentUserId,
      'timestamp': Timestamp.fromDate(DateTime.now())
    });
    DocumentReference postRef =
        postsRef.doc(post.authorId).collection('userPosts').doc(post.id);
    postRef.get().then((doc) {
      int commentCount = doc['commentCount'];
      postRef.update({'commentCount': commentCount + 1});
      // commentsRef.doc(post.id).collection('postLikes').doc(currentUserId).set({});
    });

    addActivityItem(
      currentUserId: currentUserId,
      post: post,
      comment: comment,
      isFollowEvent: false,
      isLikeMessageEvent: false,
      isCommentEvent: true,
      isLikeEvent: false,
      isMessageEvent: false,
      recieverToken: recieverToken,
    );
  }

  static void addActivityItem({
    String currentUserId,
    Post post,
    String comment,
    bool isFollowEvent,
    bool isCommentEvent,
    bool isLikeEvent,
    bool isMessageEvent,
    bool isLikeMessageEvent,
    String recieverToken,
  }) {
    if (currentUserId != post.authorId) {
      
      activitiesRef.doc(post.authorId).collection('userActivities').add({
        'fromUserId': currentUserId,
        'postId': post.id,
        'postImageUrl': post.imageUrl,
        'comment': comment,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'isFollowEvent': isFollowEvent,
        'isCommentEvent': isCommentEvent,
        'isLikeEvent': isLikeEvent,
        'isMessageEvent': isMessageEvent,
        'isLikeMessageEvent': isLikeMessageEvent,
        'recieverToken': recieverToken,
      });
    }
  }

  static void deleteActivityItem(
      {String currentUserId,
      Post post,
      String comment,
      bool isFollowEvent,
      bool isCommentEvent,
      bool isLikeEvent,
      bool isMessageEvent,
      bool isLikeMessageEvent}) async {
    String boolCondition;

    if (isFollowEvent) {
      boolCondition = 'isFollowEvent';
    } else if (isCommentEvent) {
      boolCondition = 'isCommentEvent';
    } else if (isLikeEvent) {
      boolCondition = 'isLikeEvent';
    } else if (isMessageEvent) {
      boolCondition = 'isMessageEvent';
    } else if (isLikeMessageEvent) {
      boolCondition = 'isLikeMessageEvent';
    }

    QuerySnapshot activities = await activitiesRef
        .doc(post.authorId)
        .collection('userActivities')
        .where('fromUserId', isEqualTo: currentUserId)
        .where('postId', isEqualTo: post.id)
        .where(boolCondition, isEqualTo: true)
        .get();

    activities.docs.forEach((element) {
      activitiesRef
          .doc(post.authorId)
          .collection('userActivities')
          .doc(element.id)
          .delete();
    });
  }

  static Future<List<Activity>> getActivities(String userId) async {
    QuerySnapshot userActivitiesSnapshot = await activitiesRef
        .doc(userId)
        .collection('userActivities')
        .orderBy('timestamp', descending: true)
        .get();
    List<Activity> activity = userActivitiesSnapshot.docs
        .map((doc) => Activity.fromDoc(doc))
        .toList();
    return activity;
  }

  static Future<Post> getUserPost(String userId, String postId) async {
    DocumentSnapshot postDocSnapshot =
        await postsRef.doc(userId).collection('userPosts').doc(postId).get();
    return Post.fromDoc(postDocSnapshot);
  }
}
