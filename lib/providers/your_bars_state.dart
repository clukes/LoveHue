import 'package:flutter/material.dart';

import '../models/relationship_bar_model.dart';

/// Handles current user's bars state, dealing with users current [RelationshipBarDocument].
class YourBarsState with ChangeNotifier {
  // Singleton pattern
  static final YourBarsState _instance = YourBarsState._internal();

  static YourBarsState get instance => _instance;

  YourBarsState._internal();

  factory YourBarsState() => _instance;

  /// Stores the most recent [RelationshipBarDocument].
  RelationshipBarDocument? latestRelationshipBarDoc;

  /// Gets the list of [RelationshipBar] from [latestRelationshipBarDoc].
  List<RelationshipBar>? get barList => latestRelationshipBarDoc?.barList;

  /// True if any bars have been changed since last [resetBarChange].
  bool barsChanged = false;

  /// True if all bars are to be reset to values in database.
  bool barsReset = false;

  /// Set [barsChanged] to true, and [notifyListeners].
  void barChange() {
    if (!barsChanged) {
      barsChanged = true;
      notifyListeners();
    }
  }

  /// Set [barsChanged] to false, and [notifyListeners].
  void resetBarChange() {
    if (barsChanged) {
      barsChanged = false;
      notifyListeners();
    }
  }
}
