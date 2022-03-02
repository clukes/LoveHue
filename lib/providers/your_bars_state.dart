import 'package:flutter/material.dart';

import '../models/relationship_bar_model.dart';

class YourBarsState with ChangeNotifier {
  static final YourBarsState _instance = YourBarsState._internal();

  static YourBarsState get instance => _instance;

  YourBarsState._internal();
  factory YourBarsState() => _instance;

  RelationshipBarDocument? latestRelationshipBarDoc;
  List<RelationshipBar>? get barList => latestRelationshipBarDoc?.barList;

  bool barsChanged = false;
  bool barsReset = false;

  void barChange() {
    if (!barsChanged) {
      barsChanged = true;
      print("NOTIFY BARS");
      notifyListeners();
    }
  }

  void resetBarChange() {
    if (barsChanged) {
      barsChanged = false;
      print("NOTIFY BARS");
      notifyListeners();
    }
  }
}
