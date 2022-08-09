import 'package:flutter/material.dart';

/// Screen width to switch layout.
const webScreenWidth = 900;

/// Default bar labels for new user.
const List<String> defaultBarLabels = [
  "Verbal Affection",
  "Physical Affection",
  "Undivided Attention",
  "Shared Activities",
  "Communication",
  "Responsibilities",
  "Gifts and Experiences",
];

/// App logo without text.
const AssetImage appLogo = AssetImage('assets/images/lovehue.png');

/// App logo with text.
const AssetImage appTextLogo = AssetImage('assets/images/lovehuetext.png');

const int minimumSecondsBetweenNudges = 60 * 60; //60 minutes
const int minimumMillisecondsBetweenNudges = minimumSecondsBetweenNudges * 1000;
