import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/calls/call.dart';
import 'package:Dana/calls/call_utilities.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/models/models.dart';
import 'package:Dana/services/api/database_service.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:Dana/widgets/appbar_widget.dart';
import 'package:Dana/widgets/calls_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class CallsScreen extends StatefulWidget {
  AppUser? currentUser;

  CallsScreen({this.currentUser});

  @override
  _CallsScreenState createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  late AppUser receiverUser; 

  Stream<List<Call>> getCalls() async* {
    try {
      List<Call> dataToReturn = [];

      Stream<QuerySnapshot> stream = FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.currentUser!.id)
          .collection('callHistory') 
          .snapshots();

      await for (QuerySnapshot q in stream) {
        for (var doc in q.docs) {
          Call callFromDoc = Call.fromMap(doc);

          // duration = doc['duration'];
          // timestamp = doc['timestamp'];
          receiverUser =
              await DatabaseService.getUserWithId(callFromDoc.receiverId);

          Call callWithUserInfo = Call(
              callerId: callFromDoc.callerId,
              callerName: callFromDoc.callerName,
              callerPic: callFromDoc.callerPic,
              channelId: callFromDoc.channelId,
              receiverId: callFromDoc.receiverId,
              receiverName: callFromDoc.receiverName,
              receiverPic: callFromDoc.receiverPic,
              hasDialled: callFromDoc.hasDialled,
              isMissed: callFromDoc.isMissed,
              timestamp: callFromDoc.timestamp,
              duration: callFromDoc.duration,
              isAudio: callFromDoc.isAudio);

          // dataToReturn.removeWhere((call) => call. == callWithUserInfo.id);

          dataToReturn.add(callWithUserInfo);
        }
    dataToReturn.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

        yield dataToReturn;
      }
    } catch (err) {
      print('////$err');
    }
  }

  _buildCall(Call call, String? currentUserId) {
    // final bool isRead = chat.readStatus[currentUserId];
    // widget.isReadIcon = isRead;
    // final TextStyle readStyle = TextStyle(
    //     color: isRead ? Colors.white : lightColor,
    //     fontSize: 12,
    //     fontWeight: isRead ? FontWeight.w400 : FontWeight.bold);

    // users = chat.memberInfo;
    // int receiverIndex =
    //     chat.memberInfo.indexWhere((user) => user.id != widget.currentUser.id);
    // int senderIndex =
    //     chat.memberInfo.indexWhere((user) => user.id == chat.recentSender);

    // userName = chat.memberInfo[receiverIndex].name;

    return ListTile(
        leading: Container(
          height: 40,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 28.0,
            backgroundImage: (call.receiverPic!.isEmpty
                    ? AssetImage(placeHolderImageRef)
                    : CachedNetworkImageProvider( (call.receiverName! == widget.currentUser?.name)
                ? call.callerPic!
                : call.receiverPic!,))
                as ImageProvider<Object>?,
          ),
        ),
        title: Text(
            (call.receiverName! == widget.currentUser?.name)
                ? call.callerName!
                : call.receiverName!,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        subtitle: Row(
          children: [
            call.isAudio!
                ? Icon(FontAwesomeIcons.phoneAlt, color: Colors.grey, size: 13)
                : Icon(FontAwesomeIcons.video, size: 13, color: Colors.grey),
            SizedBox(width: 10),
            if (call.isMissed == true)
              Text('Cancelled', style: TextStyle(color: Colors.red)),
            if (call.hasDialled == true)
              Text('${S.of(context)!.outgoing} (${call.duration})',
                  style: TextStyle(color: Colors.grey)),
            if (call.hasDialled == false)
              Text('${S.of(context)!.incoming} (${call.duration})',
                  style: TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: Text(timeago.format(call.timestamp!.toDate()),
            style: TextStyle(color: Colors.white)),
        onTap: () {
          if (call.isAudio!) {
            try {
              CallUtils.dial(
                  from: widget.currentUser!,
                  to: receiverUser,
                  context: context,
                  isAudio: true);
            } catch (e) {
              print('=============$e');
            }
          } else {
            try {
              CallUtils.dial(
                  from: widget.currentUser!,
                  to: receiverUser,
                  context: context,
                  isAudio: false);
            } catch (e) {
              print('=============$e');
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              title: Text(S.of(context)!.calls,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'Poppins-Regular',
                      fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              centerTitle: false,
              automaticallyImplyLeading: false,
              elevation: 0,
              brightness: Brightness.dark,
            )),
        body: StreamBuilder(
            stream: getCalls(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SpinKitWanderingCubes(color: Colors.white, size: 40),
                );
              }

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ListView.builder(
                            // reverse: true,
                            // shrinkWrap: true,
                                              itemBuilder: (BuildContext context, int index) {
                          Call call = snapshot.data[index];
                          print(
                              '=\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\${call.channelId}');
                        
                          return _buildCall(call, widget.currentUser!.id);
                                              },
                                              itemCount: snapshot.data.length,
                                            ),
                        )),
                  ],
                ),
              );
            }),

        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       SizedBox(height: 10),
        //       CallTile(audio: false, missed: true),
        //       CallTile(audio: true, missed: false),
        //       CallTile(audio: false, missed: false),
        //     ],
        //   ),
        // ),
      ),
    ]);
  }
}
