import 'package:dana/classes/language.dart';
import 'package:dana/localization/language_constants.dart';
import 'package:dana/main.dart';
import 'package:dana/screens/pages/report_issue.dart';
import 'package:dana/services/api/auth_service.dart';
import 'package:dana/utils/constants.dart';
import 'package:dana/widgets/BrandDivider.dart';
import 'package:dana/widgets/add_post_appbar.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkColor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child:
              AddPostAppbar(isTab: false, title: 'Mokolosos', isPost: false)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Terms and Privacy Policy',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  Icon(Icons.chevron_right, color: Colors.white)
                ],
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
                    Text('Report Issue',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    Icon(Icons.chevron_right, color: Colors.white)
                  ],
                ),
              ),
              SizedBox(height: 10),
              BrandDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Language',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  DropdownButton<Language>(
                    underline: SizedBox(),
                    icon: Icon(
                      Icons.language,
                      color: Colors.white,
                    ),
                    onChanged: (Language language) {
                      _changeLanguage(language);
                    },
                    items: Language.languageList()
                        .map<DropdownMenuItem<Language>>(
                          (e) => DropdownMenuItem<Language>(
                            value: e,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  child: Text('Logout',
                      style: TextStyle(color: Colors.red, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
