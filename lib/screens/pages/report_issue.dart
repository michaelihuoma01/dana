import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dana/classes/language.dart';
import 'package:dana/localization/language_constants.dart';
import 'package:dana/main.dart';
import 'package:dana/models/user_data.dart';
import 'package:dana/models/user_model.dart';
import 'package:dana/services/api/auth_service.dart';
import 'package:dana/utilities/constants.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/utils/utility.dart';
import 'package:dana/widgets/BrandDivider.dart';
import 'package:dana/widgets/add_post_appbar.dart';
import 'package:dana/widgets/appbar_widget.dart';
import 'package:dana/widgets/button_widget.dart';
import 'package:dana/widgets/textformfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatefulWidget {
  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  String emailBody;

  @override
  Widget build(BuildContext context) {
    AppUser currentUser =
        Provider.of<UserData>(context, listen: false).currentUser;
    return Scaffold(
      backgroundColor: darkColor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBarWidget(isTab: false, title: 'Contact Us')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Please describe your issue',
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
                title: 'Submit',
                onPressed: () async {
                  print(currentUser.email);
                  print(emailBody);

                  if (currentUser != null) {
                    if (emailBody.isEmpty) {
                      Utility.showMessage(context,
                          bgColor: Colors.red,
                          message: 'Field cannot be empty',
                          pulsate: false,
                          type: MessageTypes.error);
                    } else {
                      FirebaseFirestore.instance
                          .collection('issues')
                          .doc(currentUser.id)
                          .collection('userReports')
                          .add({
                        'timestamp': Timestamp.now(),
                        'issue': emailBody,
                      }).then((value) {
                        Utility.showMessage(context,
                            message:
                                'Thank you for contacting us, we\'ll get send you a follow email shortly regarding your issue.',
                            pulsate: false,
                            bgColor: Colors.green[600]);
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
    );
  }
}
