import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/calls/call.dart';
import 'package:dana/calls/call_methods.dart';
import 'package:dana/calls/callscreens/pickup/pickup_screen.dart';
import 'package:dana/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();
  final AppUser? currentUser;

  PickupLayout({required this.scaffold, this.currentUser});

  @override
  Widget build(BuildContext context) {
    // final UserProvider userProvider = Provider.of<UserProvider>(context);

    return (currentUser != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: currentUser!.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data() != null) {
                print(snapshot.data!.reference);

                Call call = Call.fromMap(snapshot.data!.data());

                if (!call.hasDialled!) {
                  return PickupScreen(call: call);
                }
              }
              return scaffold;
            },
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
