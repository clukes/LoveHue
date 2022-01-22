import 'package:flutter/material.dart';

import 'colors.dart';

final ThemeData themeData = ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.all(24),
      ),
      backgroundColor: MaterialStateProperty.all<Color>(blueColor),
      foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)))),
    )));
