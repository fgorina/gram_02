import 'package:flutter/material.dart';

class SettingsItem {

  String title;
  Widget Function(BuildContext)  detail;
  bool alwaysActive;

  SettingsItem(this.title, this.detail, this.alwaysActive);
}