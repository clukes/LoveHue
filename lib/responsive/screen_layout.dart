import 'package:flutter/material.dart';

import '../utils/navigation.dart';

/// [StatefulWidget] to extend that includes [PageController].
abstract class ScreenLayout extends StatefulWidget {
  const ScreenLayout({Key? key}) : super(key: key);
}

/// State to extend for [ScreenLayout].
abstract class ScreenLayoutState<T extends ScreenLayout> extends State<T> {
  /// Current page index.
  int page = 0;
  late PageController pageController;
  late final PageView pageView;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    pageView = PageView(
      physics: const NeverScrollableScrollPhysics(),
      children: navigationBarPages,
      controller: pageController,
      onPageChanged: onPageChanged,
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int currentPage) {
    setState(() {
      page = currentPage;
    });
  }

  void navigationTapped(int currentPage);
}
