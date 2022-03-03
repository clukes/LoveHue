import 'package:flutter/material.dart';

import '../pages/partners_bars_page.dart';
import '../pages/profile_page.dart';
import '../pages/your_bars_page.dart';

/// Pages in the navigation bar.
const List<Widget> navigationBarPages = [YourBars(), PartnersBars(), ProfilePage()];

/// Icons for each page in the navigation bar.
const List<IconData> navigationBarIcons = [Icons.person, Icons.favorite, Icons.manage_accounts];

/// Labels for each page in the navigation bar.
const List<String> navigationBarLabels = ["You", "Partner", "Account"];
