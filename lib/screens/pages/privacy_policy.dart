import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
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
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  PrivacyPolicyState createState() => PrivacyPolicyState();
}

class PrivacyPolicyState extends State<PrivacyPolicy> {
 

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
            child: AppBarWidget(isTab: false, title: S.of(context)!.tandc)),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SfPdfViewer.asset('assets/Dana Privacy Policy.pdf'),
        ),
      ),
    );
  }
}
