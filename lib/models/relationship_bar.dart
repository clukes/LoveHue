/// Holds information for a single [RelationshipBar].
///
/// A [RelationshipBar] holds an [order] number, [label] text, [prevValue] number, [value] number and [changed] check.
class RelationshipBar {
  RelationshipBar({
    required this.order,
    required this.label,
    this.prevValue = defaultBarValue,
    this.value = defaultBarValue,
    this.changed = false,
  });

  /// Gives the ordering it should be placed in the set of bars.
  int order;

  /// The text to display with the bar.
  String label;

  /// The previous value that it was set to, from 0 to 100.
  int prevValue;

  /// The current value that it is set to, from 0 to 100.
  int value;

  /// Whether it has been changed since the last save to the database.
  bool changed;

  /// Max is 100.
  static const maxBarValue = 100;

  /// Min is 0.
  static const minBarValue = 0;

  // Initial value, currently set to the max value which is 100. Thought it was more optimistic to default to max than min.
  static const defaultBarValue = maxBarValue;

  // Column names for a RelationshipBar document in the FirebaseFirestore Database.
  static const String _columnOrder = 'order';
  static const String _columnLabel = 'label';
  static const String _columnValue = 'value';
  static const String _columnPrevValue = 'prevValue';

  /// Sets [value] to the given value, and sets [prevValue] and [changed] to true, if [value] has changed.
  int setValue(int newValue) {
    if (newValue != value) {
      prevValue = value;
      value = newValue;
      changed = true;
    }
    return value;
  }

  /// Resets [value] to the [prevValue], and sets [changed] to false.
  int resetValue() {
    value = prevValue;
    changed = false;
    return value;
  }

  /// Returns [label] and [value] with format 'label: value%'.
  @override
  String toString() {
    return labelString() + valueString();
  }

  /// Returns [label] with format 'label: '.
  String labelString() {
    return label + ": ";
  }

  /// Returns [value] with format 'value: %'.
  String valueString() {
    return value.toString() + "%";
  }

  /// Converts a given [Map] to the returned [RelationshipBar].
  static RelationshipBar fromMap(Map<String, Object?> res) {
    return RelationshipBar(
      order: res[_columnOrder] as int,
      label: res[_columnLabel]! as String,
      value: res[_columnValue] is int ? res[_columnValue] as int : defaultBarValue,
      prevValue: res[_columnValue] is int ? res[_columnValue] as int : defaultBarValue,
    );
  }

  /// Converts this [RelationshipBar] to the returned [Map].
  Map<String, Object?> toMap() {
    return <String, Object?>{
      _columnOrder: order,
      _columnLabel: label,
      _columnPrevValue: prevValue,
      _columnValue: value,
    };
  }

  /// Calls [toMap] on a list of [RelationshipBar].
  static List<Map<String, Object?>>? toMapList(List<RelationshipBar>? info) {
    return info?.map((e) => e.toMap()).toList();
  }

  /// Calls [fromMap] on a list of [Map].
  static List<RelationshipBar>? fromMapList(List<Map<String, Object?>> maps) {
    maps.sort((a, b) => (a[_columnOrder] as int).compareTo(b[_columnOrder] as int));
    return maps.map((e) => fromMap(e)).toList();
  }

  /// Creates a [RelationshipBar] with default values and given label for each String in labels.
  static List<RelationshipBar> listFromLabels(List<String> labels) {
    return List<RelationshipBar>.generate(
        labels.length, (index) => RelationshipBar(order: index, label: labels[index]));
  }
}
