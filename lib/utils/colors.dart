import 'dart:ui';

import 'package:flutter/material.dart';

const mobileBackgroundColor = Colors.white;
const primaryColor = Colors.white;
const secondaryColor = Colors.blueGrey;
const blueColor = Colors.blue;
const redColor = Colors.red;
const darkTextColor = Colors.black;

const activeNavigationColor = Colors.black;
const inactiveNavigationColor = Colors.grey;

const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFB5FFFC), Color(0xFFFFDEE9)]);
const cardGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFB5FFFC), Color(0xFFFFDEE9)]);

const sliderColors = [
  SliderColor(
    Colors.red,
    Color.fromARGB(255, 198, 40, 40),
  ),
  SliderColor(
    Colors.orange,
    Color.fromARGB(255, 239, 108, 0),
  ),
  SliderColor(
    Colors.yellow,
    Color.fromARGB(255, 249, 168, 37),
  ),
  SliderColor(Colors.green, Color.fromARGB(255, 46, 125, 50)),
  SliderColor(
    Color.fromARGB(255, 46, 125, 50),
    Color.fromARGB(255, 20, 73, 26),
  ),
];

class SliderColor {
  final Color active;
  final Color inactive;

  const SliderColor(this.active, this.inactive);
}

SliderColor? getSliderColor(int sliderValue) {
  // Maps < 20 to 0 (red), < 40 to 1 (orange), < 60 to 2 (yellow) and <= 100 to 3 (green)
  int mappedToRange = ((sliderValue / 101) * sliderColors.length).floor();
  return sliderColors[mappedToRange];
  // if (sliderValue >= 60) {
  //   return sliderColors['Green'];
  // } else if (sliderValue >= 40) {
  //   return sliderColors['Yellow'];
  // } else if (sliderValue >= 20) {
  //   return sliderColors['Orange'];
  // } else {
  //   return sliderColors['Red'];
  // }
}
