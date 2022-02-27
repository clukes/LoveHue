import 'package:flutter/material.dart';
import 'package:relationship_bars/responsive/screen_layout.dart';
import 'package:relationship_bars/utils/colors.dart';
import 'package:relationship_bars/utils/globals.dart';

class WebScreenLayout extends ScreenLayout {
  const WebScreenLayout({Key? key}) : super(key: key);

  @override
  _WebScreenLayoutState createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends ScreenLayoutState {
  @override
  void navigationTapped(int currentPage) {
    pageController.jumpToPage(currentPage);
    setState(() {
      page = currentPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              navigationBarIcons[0],
              color: page == 0 ? activeNavigationColor : inactiveNavigationColor,
            ),
            onPressed: () => navigationTapped(0),
          ),
          IconButton(
            icon: Icon(
              navigationBarIcons[1],
              color: page == 1 ? activeNavigationColor : inactiveNavigationColor,
            ),
            onPressed: () => navigationTapped(1),
          ),
          IconButton(
            icon: Icon(
              navigationBarIcons[2],
              color: page == 2 ? activeNavigationColor : inactiveNavigationColor,
            ),
            onPressed: () => navigationTapped(2),
          ),
        ],
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        children: navigationBarItems,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
    );
  }
}
