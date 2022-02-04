import 'package:flutter/material.dart';
import 'package:relationship_bars/pages/partners_bars_page.dart';
import 'package:relationship_bars/pages/profile_page.dart';
import 'package:relationship_bars/pages/your_bars_page.dart';

const webScreenSize = 900;

List<Widget> navigationBarItems = [
  const YourBars(),
  const PartnersBars(),
  const ProfilePage(),
];

List<IconData> navigationBarIcons = [
  Icons.person,
  Icons.favorite,
  Icons.settings,
];

const List<String> navigationBarLabels = ["You", "Partner", "Settings"];
