import 'package:flutter/material.dart';

import '../responsive/mobile_screen_layout.dart';
import '../utils/globals.dart';

const ResponsiveLayout responsiveLayout = ResponsiveLayout(
  mobileScreenLayout: MobileScreenLayout(),
  webScreenLayout: MobileScreenLayout(),
);

class ResponsiveLayout extends StatelessWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

  const ResponsiveLayout({Key? key, required this.webScreenLayout, required this.mobileScreenLayout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > webScreenSize) {
          return webScreenLayout;
        }
        return mobileScreenLayout;
      },
    );
  }
}
