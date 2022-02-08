import 'dart:ui';

import 'package:flutter/material.dart';

const mobileBackgroundColor = Colors.white;
const primaryColor = Colors.white;
const secondaryColor = Colors.blueGrey;
const blueColor = Colors.blue;
const redColor = Colors.red;

const activeNavigationColor = Colors.black;
const inactiveNavigationColor = Colors.grey;

const backgroundGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFB5FFFC), Color(0xFFFFDEE9)]);
const cardGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFB5FFFC), Color(0xFFFFDEE9)]);

const Map<String, SliderColor> sliderColors = {
  'Green': SliderColor(
      Color.fromARGB(255,38,243,12),
      Color.fromARGB(255,19,153,19)
  ),
  'Yellow': SliderColor(
      Colors.yellow,
    Color.fromARGB(255, 249, 168, 37),
  ),
  'Orange': SliderColor(

    Colors.orange,
    Color.fromARGB(255, 239, 108, 0),
),
  'Red': SliderColor(
      Colors.red,
      Color.fromARGB(255, 198, 40, 40),
  ),
};

class SliderColor {
  final Color active;
  final Color inactive;

  const SliderColor(this.active, this.inactive);
}

SliderColor? getSliderColor(int sliderValue) {
  if(sliderValue >= 60) {
    return sliderColors['Green'];
  } else if(sliderValue >= 40) {
    return sliderColors['Yellow'];
  } else if(sliderValue >= 20) {
    return sliderColors['Orange'];
  } else {
    return sliderColors['Red'];
  }
}