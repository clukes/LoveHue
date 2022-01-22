import 'package:flutter/material.dart';
import 'package:relationship_bars/responsive/screen_layout.dart';
import 'package:relationship_bars/utils/colors.dart';
import 'package:relationship_bars/utils/globals.dart';

class MobileScreenLayout extends ScreenLayout {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  _MobileScreenLayoutState createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends ScreenLayoutState {
  @override
  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        children: navigationBarItems,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: null,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              navigationBarIcons[0],
            ),
            label: navigationBarLabels[0],
          ),
          BottomNavigationBarItem(
              icon: Icon(
                navigationBarIcons[1],
              ),
              label: navigationBarLabels[1],
          ),
          BottomNavigationBarItem(
              icon: Icon(
                navigationBarIcons[2],
              ),
              label: navigationBarLabels[2],
          )
        ],
        onTap: navigationTapped,
        currentIndex: page,
        selectedItemColor: activeNavigationColor,
        unselectedItemColor: inactiveNavigationColor,
      ),
    ),
    );
  }
}
