import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'custom_shapes.dart';

final ThemeData themeData = ThemeData.light().copyWith(
    colorScheme: colorScheme,
    primaryColor: primaryColor,
    backgroundColor: mobileBackgroundColor,
    scaffoldBackgroundColor: mobileBackgroundColor,
    brightness: Brightness.light,
    textTheme: textTheme,
    primaryTextTheme: primaryTextTheme,
    appBarTheme: const AppBarTheme(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(10, 5), bottomRight: Radius.elliptical(10, 5))),
      backgroundColor: mobileBackgroundColor,
      foregroundColor: primaryTextColor,
      elevation: 0.0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: navigationBackgroundColor,
      selectedItemColor: activeNavigationColor,
      unselectedItemColor: inactiveNavigationColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    cardTheme: const CardTheme(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 30.0,
      thumbColor: null,
      overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
      tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 0),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0, elevation: 0, pressedElevation: 0),
      trackShape: CustomRoundedSliderTrackShape(),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(191, 0, 147, 233),
      elevation: 0,
      highlightElevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
    ));

final TextTheme primaryTextTheme = GoogleFonts.dmSansTextTheme(ThemeData.from(colorScheme: colorScheme).textTheme);

final TextTheme dmSansTextTheme = primaryTextTheme.copyWith(
  headline6: const TextStyle(fontWeight: FontWeight.w700, fontSize: 28, color: primaryTextColor),
  subtitle1: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: primaryTextColor),
);

//Allows for other fonts
final TextTheme textTheme = dmSansTextTheme.copyWith(
  subtitle2: GoogleFonts.poppins(fontWeight: FontWeight.normal, fontSize: 16, color: secondaryTextColor),
);
