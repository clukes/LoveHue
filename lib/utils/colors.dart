import 'package:flutter/material.dart';

const mobileBackgroundColor = Color.fromARGB(255, 255, 248, 235);
const primaryColor = Colors.white;
const blueColor = Colors.blue;
const redColor = Colors.red;
const primaryTextColor = Color.fromARGB(255, 51, 51, 51);
const secondaryTextColor = Color.fromARGB(255, 105, 105, 105);

final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: primaryColor);

const navigationBackgroundColor = Color.fromARGB(255, 253, 254, 255);
const activeNavigationColor = Color.fromARGB(255, 42, 167, 223);
const inactiveNavigationColor = Color.fromARGB(255, 176, 195, 206);

const cardGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x2482D6FF), Color(0x26D7F1FF)]);

const alpha = 102;
const sliderColors = [
  SliderColor(
    Color.fromARGB(255, 235, 87, 87),
    Color.fromARGB(alpha, 235, 87, 87),
  ),
  SliderColor(
    Color.fromARGB(255, 242, 153, 74),
    Color.fromARGB(alpha, 242, 153, 74),
  ),
  SliderColor(
    Color.fromARGB(255, 242, 201, 76),
    Color.fromARGB(alpha, 242, 201, 76),
  ),
  SliderColor(
    Color.fromARGB(255, 127, 217, 38),
    Color.fromARGB(alpha, 127, 217, 38),
  ),
  SliderColor(
    Color.fromARGB(255, 4, 196, 115),
    Color.fromARGB(alpha, 4, 196, 115),
  ),
];

class SliderColor {
  final Color active;
  final Color inactive;

  const SliderColor(this.active, this.inactive);
}

SliderColor? getSliderColor(int sliderValue) {
  // Maps < 20 to 0 (red), < 40 to 1 (orange), etc.
  int mappedToRange = ((sliderValue / 101) * sliderColors.length).floor();
  return sliderColors[mappedToRange];
}
