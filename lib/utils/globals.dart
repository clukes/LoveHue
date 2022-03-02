import 'package:flutter/material.dart';

import '../pages/partners_bars_page.dart';
import '../pages/profile_page.dart';
import '../pages/your_bars_page.dart';

const webScreenSize = 900;

const List<Widget> navigationBarItems = [
  YourBars(),
  PartnersBars(),
  ProfilePage(),
];

const List<IconData> navigationBarIcons = [
  Icons.person,
  Icons.favorite,
  Icons.manage_accounts,
];

const List<String> navigationBarLabels = ["You", "Partner", "Account"];

const List<String> defaultBarLabels = [
  "Words of Affirmation",
  "Quality Time",
  "Giving Gifts",
  "Acts of Service",
  "Physical Touch",
];
