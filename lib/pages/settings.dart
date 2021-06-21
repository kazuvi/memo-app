import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';


class Setting extends StatefulWidget {
  Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool test = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SettingsList(
        sections: [
          SettingsSection(
            title: 'Section',
            tiles: [
              SettingsTile(
                title: 'Language',
                subtitle: 'English',
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile.switchTile(
                title: 'Use fingerprint',
                leading: Icon(Icons.fingerprint),
                switchValue: test,
                onToggle: (bool value) {},
              ),
            ],
          ),
        ],
      )
,
    );
  }
}