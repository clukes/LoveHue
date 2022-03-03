import 'package:flutter/material.dart';

import '../responsive/screen_layout.dart';
import '../utils/globals.dart';
import '../utils/navigation.dart';

/// Vertical layout with [BottomNavigationBar] for screen size <= [webScreenSize].
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
    return Scaffold(
      body: pageView,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(color: Color.fromARGB(38, 0, 0, 0), blurRadius: 20, offset: Offset(0, 0.75))
          ],
        ),
        child: BottomNavigationBar(
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
        ),
      ),
    );
  }
}
