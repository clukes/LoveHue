import 'package:flutter/material.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';

class YourBarsState extends ChangeNotifier {
  static final YourBarsState _instance = YourBarsState._internal();

  static YourBarsState get instance => _instance;

  YourBarsState._internal();
  factory YourBarsState() => _instance;

  RelationshipBarDocument? _latestRelationshipBarDoc;
  RelationshipBarDocument? get latestRelationshipBarDoc => _latestRelationshipBarDoc;
  List<RelationshipBar>? get barList => latestRelationshipBarDoc?.barList;

  set latestRelationshipBarDoc(RelationshipBarDocument? latestRelationshipBarDoc) {
    _latestRelationshipBarDoc = latestRelationshipBarDoc;
    print("NOTIFY BARS");
    notifyListeners();
  }

  bool barsChanged = false;
  bool barsReset = false;

  void barChange() {
    barsChanged = true;
    print("NOTIFY BARS");
    notifyListeners();
  }

  void resetBarChange() {
    barsChanged = false;
    print("NOTIFY BARS");
    notifyListeners();
  }
}
