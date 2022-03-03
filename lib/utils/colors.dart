import 'package:flutter/material.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';

/// Various colors to use in the app.
const mobileBackgroundColor = Color.fromARGB(255, 255, 248, 235);
const primaryColor = Colors.white;
const blueColor = Colors.blue;
const redColor = Colors.red;
const primaryTextColor = Color.fromARGB(255, 51, 51, 51);
const secondaryTextColor = Color.fromARGB(255, 105, 105, 105);

/// Built [ColorScheme] from [primaryColor].
final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: primaryColor);

/// Navigation colors.
const navigationBackgroundColor = Color.fromARGB(255, 253, 254, 255);
const activeNavigationColor = Color.fromARGB(255, 42, 167, 223);
const inactiveNavigationColor = Color.fromARGB(255, 176, 195, 206);

/// Gradient for the slider cards.
const cardGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x2482D6FF), Color(0x26D7F1FF)]);

const shadowColor = Color.fromARGB(64, 0, 0, 0);
const floatingButtonColor = Color.fromARGB(191, 0, 147, 233);

const _sliderRed = Color.fromARGB(255, 235, 87, 87);
const _sliderOrange = Color.fromARGB(255, 242, 153, 74);
const _sliderYellow = Color.fromARGB(255, 242, 201, 76);
const _sliderGreen = Color.fromARGB(255, 127, 217, 38);
const _sliderBrightGreen = Color.fromARGB(255, 4, 196, 115);

/// List of colors for a slider.
final sliderColors = [
  SliderColor.fromActive(_sliderRed),
  SliderColor.fromActive(_sliderOrange),
  SliderColor.fromActive(_sliderYellow),
  SliderColor.fromActive(_sliderGreen),
  SliderColor.fromActive(_sliderBrightGreen),
];

/// Color information for a slider.
class SliderColor {
  /// Color for the active side of the slider.
  final Color active;
  /// Color for the inactive side of the slider.
  final Color inactive;

  // Alpha to apply to active color for inactive color
  static const _inactiveAlpha = 102;

  const SliderColor(this.active, this.inactive);

  SliderColor.fromActive(this.active) : inactive = active.withAlpha(_inactiveAlpha);
}

/// Gets slider color for a given value.
SliderColor? getSliderColor(int sliderValue) {
  // Maps x < 20 to 0 (red), 20 < x < 40 to 1 (orange), etc.
  int mappedToRange = ((sliderValue / (RelationshipBar.maxBarValue+1)) * sliderColors.length).floor();
  return sliderColors[mappedToRange];
}
