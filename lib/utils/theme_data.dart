import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'custom_shapes.dart';

final ThemeData lightThemeData = ThemeData.light().copyWith(
    colorScheme: colorScheme,
    primaryColor: primaryColor,
    backgroundColor: mobileBackgroundColor,
    scaffoldBackgroundColor: mobileBackgroundColor,
    brightness: Brightness.light,
    textTheme: _textTheme,
    primaryTextTheme: _primaryTextTheme,
    appBarTheme: const AppBarTheme(
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
      backgroundColor: floatingButtonColor,
      elevation: 0,
      highlightElevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
    ),
);

// Default theme for primary text.
final TextTheme _primaryTextTheme = GoogleFonts.dmSansTextTheme(ThemeData.from(colorScheme: colorScheme).textTheme);


final TextTheme _dmSansTextTheme = _primaryTextTheme.copyWith(
  headline6: const TextStyle(fontWeight: FontWeight.w700, fontSize: 28, color: primaryTextColor),
  subtitle1: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: primaryTextColor),
);
// Theme for non-primary text with a secondary font.
final TextTheme _textTheme = _dmSansTextTheme.copyWith(
  subtitle2: GoogleFonts.poppins(fontWeight: FontWeight.normal, fontSize: 16, color: secondaryTextColor),
);
