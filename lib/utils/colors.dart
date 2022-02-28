import 'package:flutter/material.dart';

const mobileBackgroundColor = Color.fromARGB(255, 255, 248, 235);
const primaryColor = Colors.white;
const blueColor = Colors.blue;
const redColor = Colors.red;
const primaryTextColor = Color.fromARGB(255, 51, 51, 51);
const secondaryTextColor = Color.fromARGB(255, 105, 105, 105);

const navigationBackgroundColor = Color.fromARGB(255, 253, 254, 255);
const activeNavigationColor = Color.fromARGB(255, 42, 167, 223);
const inactiveNavigationColor = Color.fromARGB(255, 176, 195, 206);

const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.fromARGB(77, 81, 186, 212), Color.fromARGB(255, 255, 248, 235), Colors.white]);
const cardGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x2144C5FF), Color(0x26B4E6FD)]);
const navigationGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, Color.fromARGB(
    255, 42, 167, 223)]);

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
