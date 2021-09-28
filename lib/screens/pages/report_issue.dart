import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:Dana/services/api/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Dana/classes/language.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/localization/language_constants.dart';
import 'package:Dana/main.dart';
import 'package:Dana/models/user_data.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/services/api/auth_service.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/utils/utility.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:Dana/widgets/add_post_appbar.dart';
import 'package:Dana/widgets/appbar_widget.dart';
import 'package:Dana/widgets/button_widget.dart';
import 'package:Dana/widgets/textformfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatefulWidget {
  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  String? emailBody;

  @override
  Widget build(BuildContext context) {
    AppUser? currentUser =
        Provider.of<UserData>(context, listen: false).currentUser;
    return PickupLayout(
         currentUser: currentUser,
      scaffold: Scaffold(
        backgroundColor: darkColor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBarWidget(isTab: false, title: S.of(context)!.contact)),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context)!.describe,
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 10),
                TextFormField(
                    cursorColor: Colors.white,
                    maxLines: 15,
                    onChanged: (value) {
                      emailBody = value;
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: lightColor, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: lightColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: lightColor, width: 1)))),
                SizedBox(height: 20),
                ButtonWidget(
                  title: S.of(context)!.submit,
                  onPressed: () async {
                    print(currentUser!.email);
                    print(emailBody);
    
                    if (currentUser != null) {
                      if (emailBody!.isEmpty) {
                        Utility.showMessage(context,
                            bgColor: Colors.red,
                            message: 'Field cannot be empty',
                            pulsate: false,
                            type: MessageTypes.error);
                      } else {
                        FirebaseFirestore.instance.collection('issues').add({
                          'timestamp': DatabaseService.formatMyDate(
                              DateTime.now().toString()),
                          'authorId': currentUser.id,
                          'userEmail': currentUser.email,
                          'userPin': currentUser.pin,
                          'issue': emailBody,
                        }).then((value) {
                          FirebaseFirestore.instance
                              .collection('issues')
                              .doc(value.id)
                              .update({'id': value.id});
                          Utility.showMessage(context,
                              message:
                                  'Thank you for contacting us, we\'ll get send you a follow email shortly regarding your issue.',
                              pulsate: false,
                              bgColor: Colors.green[600]!);
                        });
                      }
                    }
                    // final Email email = Email(
                    //   body: emailBody,
                    //   subject: 'Dana Complaint from ${currentUser.pin}',
                    //   recipients: ['michaelihuoma01@gmail.com'],
                    //   // cc: ['cc@example.com'],
                    //   // bcc: ['bcc@example.com'],
                    //   // attachmentPaths: ['/path/to/attachment.zip'],
                    //   isHTML: false,
                    // );
    
                    // await FlutterEmailSender.send(email)
                    //     .then((value) => print('Sent'));
                  },
                  iconText: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
