import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relationship_bars/pages/partners_bars_page.dart';
import 'package:relationship_bars/pages/profile_page.dart';
import 'package:relationship_bars/pages/your_bars_page.dart';
import 'package:relationship_bars/providers/your_bars_state.dart';

const webScreenSize = 900;

List<Widget> navigationBarItems = [
  ChangeNotifierProvider.value(
      value: YourBarsState.instance, builder: (context, _) => const YourBars()),
  const PartnersBars(),
  const ProfilePage(),
];

List<IconData> navigationBarIcons = [
  Icons.person,
  Icons.favorite,
  Icons.settings,
];

const List<String> navigationBarLabels = [
  "Yours",
  "Partners",
  "Settings"
];
