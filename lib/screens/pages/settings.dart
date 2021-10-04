import 'package:Dana/calls/callscreens/pickup/pickup_layout.dart';
import 'package:Dana/classes/language.dart';
import 'package:Dana/generated/l10n.dart';
import 'package:Dana/localization/language_constants.dart';
import 'package:Dana/main.dart';
import 'package:Dana/models/user_data.dart';
import 'package:Dana/models/user_model.dart';
import 'package:Dana/screens/pages/privacy_policy.dart';
import 'package:Dana/screens/pages/report_issue.dart';
import 'package:Dana/services/api/auth_service.dart';
import 'package:Dana/services/api/database_service.dart';
import 'package:Dana/utilities/constants.dart';
import 'package:Dana/utils/constants.dart';
import 'package:Dana/widgets/BrandDivider.dart';
import 'package:Dana/widgets/add_post_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switcher_button/switcher_button.dart';

class SettingsScreen extends StatefulWidget {
  // AppUser? currentUser;

  // SettingsScreen({this.currentUser});
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  String? currentUserId;
  AppUser? currentUser;

  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUserId =
        Provider.of<UserData>(context, listen: false).currentUser!.id;
    getUser();
  }

  getUser() async {
    currentUser = await DatabaseService.getUserWithId(currentUserId!);
  }

  @override
  Widget build(BuildContext context) {
   var myUser = Provider.of<UserData>(context, listen: false).currentUser;
    return PickupLayout(
      currentUser: myUser!,
      scaffold: Scaffold(
        backgroundColor: darkColor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AddPostAppbar(isTab: false, isPost: false)),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text('Notifications and sounds',
                //         style: TextStyle(color: Colors.white, fontSize: 18)),
                //     Icon(Icons.chevron_right, color: Colors.white)
                //   ],
                // ),
                // SizedBox(height: 10),
                // BrandDivider(),
                // SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PrivacyPolicy()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(S.of(context)!.tandc,
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      Icon(Icons.chevron_right, color: Colors.white)
                    ],
                  ),
                ),
                SizedBox(height: 10),
                BrandDivider(),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ReportScreen()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(S.of(context)!.report,
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      Icon(Icons.chevron_right, color: Colors.white)
                    ],
                  ),
                ),
                SizedBox(height: 10),
                BrandDivider(),
                SizedBox(height: 10),
                // GestureDetector(
                //   onTap: () {
                //     showModalBottomSheet(
                //         context: context,
                //         builder: (context) {
                //           return Container(
                //             color: darkColor,
                //             height: 100,
                //             child: Column(
                //               children: <Widget>[
                //                 GestureDetector(
                //                   onTap: () async {
                //                     usersRef
                //                         .doc(currentUser!.id)
                //                         .update({'isPublic': false}).then(
                //                             (value) => Navigator.pop(context));
                //                   },
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(top: 18),
                //                     child: Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.center,
                //                       children: [
                //                         Text('Private',
                //                             style: TextStyle(
                //                                 color: Colors.white,
                //                                 fontSize: 18)),
                //                         SizedBox(width: 10),
                //                         if (currentUser!.isPublic == false)
                //                           Icon(Icons.done, color: Colors.green)
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //                 GestureDetector(
                //                   onTap: () async {
                //                     usersRef
                //                         .doc(currentUser!.id)
                //                         .update({'isPublic': true}).then(
                //                             (value) => Navigator.pop(context));
                //                     setState(() {});
                //                   },
                //                   child: Padding(
                //                     padding: const EdgeInsets.only(top: 20),
                //                     child: Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.center,
                //                       children: [
                //                         Text('Public',
                //                             style: TextStyle(
                //                                 color: Colors.white,
                //                                 fontSize: 20)),
                //                         SizedBox(width: 10),
                //                         if (currentUser!.isPublic == true)
                //                           Icon(Icons.done, color: Colors.green)
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           );
                //         });
                //   },
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text('Account Mode',
                //           style: TextStyle(color: Colors.white, fontSize: 18)),

                //       Icon(Icons.arrow_drop_down, color: Colors.white)
                //       // SwitcherButton(
                //       //   onColor: lightColor,
                //       //   offColor: Colors.grey,
                //       //   size: 40,
                //       //   value: (currentUser!.isPublic == true) ? false : true,
                //       //   onChange: (value) {
                //       //     usersRef.doc(currentUser!.id).update({
                //       //       'isPublic':
                //       //           (currentUser!.isPublic == true) ? false : true
                //       //     });
                //       //     setState(() {});
                //       //     print(value);
                //       //   },
                //       // )
                //     ],
                //   ),
                // ),
                // SizedBox(height: 10),
                // BrandDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.of(context)!.formFieldChangeLanguage,
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    DropdownButton<Language>(
                      underline: SizedBox(),
                      icon: Icon(
                        Icons.language,
                        color: Colors.white,
                      ),
                      onChanged: (Language? language) {
                        _changeLanguage(language!);
                      },
                      items: Language.languageList()
                          .map<DropdownMenuItem<Language>>(
                            (e) => DropdownMenuItem<Language>(
                              value: e,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text(
                                    e.flag,
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  Text(e.name)
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => AuthService.logout(context),
                  child: Center(
                    child: Text(S.of(context)!.logout,
                        style: TextStyle(color: Colors.red, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
