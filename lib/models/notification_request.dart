import '../services/database_service.dart';

class NotificationRequest extends Mappable {
  static const String columnRequested = "requestedTimestampMilliseconds";
  static const String columnCompleted = "completedTimestampMilliseconds";

  final int requestedTimestampMilliseconds;
  final int? completedTimestampMilliseconds;

  NotificationRequest(this.requestedTimestampMilliseconds,
      {this.completedTimestampMilliseconds});

  /// Converts this [LinkCode] to the returned [Map].
  @override
  Map<String, Object?> toMap() {
    return <String, Object?>{
      columnRequested: requestedTimestampMilliseconds,
      columnCompleted: completedTimestampMilliseconds,
    };
  }

  /// Converts this [LinkCode] to the returned [Map], only with the non null values.
  @override
  Map<String, Object> toMapIgnoreNulls() {
    var map = <String, Object>{};
    _addToMapIfNotNull(map, columnRequested, requestedTimestampMilliseconds);
    _addToMapIfNotNull(map, columnCompleted, completedTimestampMilliseconds);
    return map;
  }

  _addToMapIfNotNull(Map<String, Object> map, String key, Object? value) {
    if (value != null) {
      map[key] = value;
    }
  }
}
