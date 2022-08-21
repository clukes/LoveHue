import 'package:clock/clock.dart';
import 'package:lovehue/services/shared_preferences_service.dart';
import 'package:lovehue/utils/globals.dart';

import 'database_service.dart';

/// Service to send notifications.
class NotificationService {
  static const String lastNudgeTimestampKey = "LastNudgeTimestamp";

  final SharedPreferencesService _prefsService;
  final DatabaseService _databaseService;
  final Clock clock;

  NotificationService(this._prefsService, this._databaseService, {this.clock = const Clock()});

  static String _baseCollectionPath(String userId) => "nudgeNotifications/{userId}";
  static String _requestedDocumentPath(String userId) => "${_baseCollectionPath(userId)}/requested";
  static String _completedDocumentPath(String userId) => "${_baseCollectionPath(userId)}/completed";

  /// Sends nudge notification to partner if it has been long enough since last nudge.
  Future<NudgeResult> sendNudgeNotification(String? currentUserId) async {
    if(currentUserId == null || currentUserId.isEmpty) {
      return NudgeResult(false, errorMessage: "No User Id.");
    }

    int milliSecondsSinceLastNudge = _getMillisecondsSinceLastNudge();
    if (!_hasItBeenEnoughMillisecondsBetweenNudges(
        milliSecondsSinceLastNudge)) {
      String errorMsg = _getMinutesToWaitMessage(milliSecondsSinceLastNudge);
      return NudgeResult(false, errorMessage: errorMsg);
    }

    int timestamp = _getCurrentTimeStamp();

    _saveNudgeRequest(timestamp, currentUserId);

    await _prefsService.setInt(lastNudgeTimestampKey, timestamp);

    return NudgeResult(true);
  }

  /// Checks if it has been long enough since last nudge.
  bool canSendNudgeNotification() => _hasItBeenEnoughMillisecondsBetweenNudges(
      _getMillisecondsSinceLastNudge());

  bool _hasItBeenEnoughMillisecondsBetweenNudges(
          int milliSecondsSinceLastNudge) =>
      _getMillisecondsSinceLastNudge() >= minimumMillisecondsBetweenNudges;

  int _getMillisecondsSinceLastNudge() {
    var lastTimestamp = _prefsService.getInt(lastNudgeTimestampKey);
    lastTimestamp ??= 0;

    return _getCurrentTimeStamp() - lastTimestamp;
  }

  int _getCurrentTimeStamp() => clock.now().millisecondsSinceEpoch;

  String _getMinutesToWaitMessage(int milliSecondsSinceLastNudge) {
    int milliSecondsToWait =
        minimumMillisecondsBetweenNudges - milliSecondsSinceLastNudge;
    Duration timeToWait = Duration(milliseconds: milliSecondsToWait);
    String errorMsg =
        'Wait ${_formatDuration(timeToWait)} minutes to nudge again.';
    return errorMsg;
  }

  String _formatDuration(Duration duration) =>
      "${duration.inMinutes}:${(duration.inSeconds.remainder(60))}";

  void _saveNudgeRequest(int milliseconds, String userId) =>
    _databaseService.saveTimestampAsync(_requestedDocumentPath(userId), lastNudgeTimestampKey, milliseconds);
}

/// Result of trying to send a nudge notification, with an error message if unsuccessful.
class NudgeResult {
  final bool successful;
  final String? errorMessage;

  NudgeResult(this.successful, {this.errorMessage});
}
