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
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class CallsScreen extends StatefulWidget {
  AppUser? currentUser;

  CallsScreen({this.currentUser});

  @override
  _CallsScreenState createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  AppUser? receiverUser;
  String _searchText = '';
  TextEditingController _searchController = TextEditingController();
  Future<Map<String, Call>>? _users;
  bool isCaller = false;
  List<String>? callerID = [];
  Map count = {};

  Stream<List<Call>> getCalls() async* {
    // try {
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

          dataToReturn.add(callWithUserInfo);
  

        dataToReturn.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
      }

      yield dataToReturn;
    }
    // } catch (err) {
    //   print('////$err');
    // }
  }

  _buildCall(Call call, String? currentUserId) {
    return ListTile(
        leading: Container(
          height: 40,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 28.0,
            backgroundImage: (call.receiverPic!.isEmpty
                ? AssetImage(placeHolderImageRef)
                : CachedNetworkImageProvider(
                    (call.receiverName! == widget.currentUser?.name)
                        ? call.callerPic!
                        : call.receiverPic!,
                  )) as ImageProvider<Object>?,
          ),
        ),
        title: (call.receiverName! == widget.currentUser?.name)
            ? Text(call.callerName!,
                style: TextStyle(
                    color: (call.isMissed == true) ? Colors.red : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16))
            : (call.callerName! == widget.currentUser?.name)
                ? Text(call.receiverName!,
                    style: TextStyle(
                        color:
                            (call.isMissed == true) ? Colors.red : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16))
                : Text('User',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
        subtitle: Row(
          children: [
            call.isAudio!
                ? Icon(FontAwesomeIcons.phoneAlt, color: Colors.grey, size: 12)
                : Icon(FontAwesomeIcons.video, size: 12, color: Colors.grey),
            SizedBox(width: 10),
            if (call.isMissed == true)
              Text('Cancelled', style: TextStyle(color: Colors.grey)),
            if (call.hasDialled == true)
              Text('${S.of(context)!.outgoing} (${call.duration})',
                  style: TextStyle(color: Colors.grey)),
            if (call.hasDialled == false)
              Text('${S.of(context)!.incoming} (${call.duration})',
                  style: TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: Text(timeago.format(call.timestamp!.toDate()),
            style: TextStyle(color: Colors.grey)),
        onTap: () {
          if (call.isAudio!) {
            try {
              CallUtils.dial(
                  from: widget.currentUser!,
                  to: receiverUser!,
                  context: context,
                  isAudio: true);
            } catch (e) {
              print('=============$e');
            }
          } else {
            try {
              CallUtils.dial(
                  from: widget.currentUser!,
                  to: receiverUser!,
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
    void _clearSearch() {
      WidgetsBinding.instance!
          .addPostFrameCallback((_) => _searchController.clear());
      setState(() {
        _users = null;
        _searchText = '';
      });
    }

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
            preferredSize: const Size.fromHeight(65),
            child: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(S.of(context)!.calls,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontFamily: 'Poppins-Regular',
                          fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: 'Search',
                        suffixIcon: _searchText.trim().isEmpty
                            ? null
                            : GestureDetector(
                                onTap: _clearSearch,
                                child: Icon(Icons.clear, color: Colors.white),
                              ),
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.white)),
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    onChanged: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          _searchText = value;
                          String? sentence = toBeginningOfSentenceCase(value);

                          if (callerID!.contains(widget.currentUser!.id)) {
                            isCaller = true;
                            print('============+++++Truueeeeeee');
                          } else {
                            isCaller = false;
                            print('============+++++Falseeeeee');
                          }

                          _users = DatabaseService.searchCalls(
                              sentence, widget.currentUser!.id, isCaller);
                        });
                      }
                    },
                    onSubmitted: (input) {
                      if (input.trim().isNotEmpty) {
                        setState(() {
                          _searchText = input;
                          String? sentence = toBeginningOfSentenceCase(input);

                          _users = DatabaseService.searchCalls(
                              sentence, widget.currentUser!.id, isCaller);
                        });
                      }
                    },
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
              centerTitle: false,
              automaticallyImplyLeading: false,
              elevation: 0,
              brightness: Brightness.dark,
            )),
        body: (_users == null)
            ? StreamBuilder(
                stream: getCalls(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: SpinKitFadingCircle(color: Colors.white, size: 40),
                    );
                  }

                  return ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      Call call = snapshot.data[index];

                      return _buildCall(call, widget.currentUser!.id);
                    },
                    itemCount: snapshot.data.length,
                  );
                })
            : FutureBuilder(
                future: _users,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: SpinKitFadingCircle(color: Colors.white, size: 40),
                    );
                  }

                  if ((snapshot.data!).length == 0) {
                    return Center(
                      child: Text('No record!',
                          style: TextStyle(color: Colors.white)),
                    );
                  }

                  return Expanded(
                      child: Align(
                    alignment: Alignment.topCenter,
                    child: ListView.builder(
                      itemCount: (snapshot.data!).length,
                      itemBuilder: (BuildContext context, int index) {
                        // Call call = snapshot.data[index];

                        Call call = (snapshot.data!).values.elementAt(index);

                        return _buildCall(call, widget.currentUser!.id);
                      },
                    ),
                  ));
                }),
      ),
    ]);
  }
}
