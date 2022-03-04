import 'package:flutter/material.dart';
import 'package:lovehue/responsive/web_screen_layout.dart';

import '../responsive/mobile_screen_layout.dart';
import '../utils/globals.dart';

/// [ResponsiveLayout] setup with [MobileScreenLayout] and [WebScreenLayout].
const ResponsiveLayout responsiveLayout = ResponsiveLayout(
  mobileScreenLayout: MobileScreenLayout(),
  webScreenLayout: WebScreenLayout(),
);

/// Builds [WebScreenLayout] or [MobileScreenLayout] depending on screen size.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({Key? key, required this.webScreenLayout, required this.mobileScreenLayout}) : super(key: key);

  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

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
