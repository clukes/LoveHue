import 'package:flutter/cupertino.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';

class YourBarsState extends ChangeNotifier {
  static final YourBarsState _instance = YourBarsState._internal();

  static YourBarsState get instance => _instance;

  YourBarsState._internal();
  factory YourBarsState() => _instance;

  List<RelationshipBar>? _yourRelationshipBars;
  List<RelationshipBar>? get yourRelationshipBars => _yourRelationshipBars;

  set yourRelationshipBars(List<RelationshipBar>? yourRelationshipBars) {
    _yourRelationshipBars = yourRelationshipBars;
    notifyListeners();
  }

  bool barsChanged = false;
  bool barsReset = false;

  void barChange() {
    barsChanged = true;
    notifyListeners();
  }

  void resetBarChange() {
    barsChanged = false;
    notifyListeners();
  }
}
