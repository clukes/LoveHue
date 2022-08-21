import 'package:clock/clock.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lovehue/services/shared_preferences_service.dart';

import '../models/notification_request.dart';
import '../utils/configs.dart';
import 'database_service.dart';

/// Service to send notifications.
class NotificationService {
  static const String lastNudgeTimestampKey = "LastNudgeTimestamp";

  final SharedPreferencesService _prefsService;
  final DatabaseService _databaseService;
  final NotificationsConfig _config;
  final Clock clock;
  late final FirebaseMessaging firebaseMessaging;

  NotificationService(this._prefsService, this._databaseService, this._config,
      {this.clock = const Clock(), FirebaseMessaging? firebaseMessaging}) {
    this.firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;
  }

  String notificationDocumentPath(String userId) =>
      "${_config.notificationCollectionPath}/$userId";

  /// Sends nudge notification to partner if it has been long enough since last nudge.
  Future<NudgeResult> sendNudgeNotification(String? currentUserId) async {
    if (currentUserId == null || currentUserId.isEmpty) {
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

  /// Subscribe to notifications from partner, by subscribing to topic with [partnersId].
  Future<void> subscribeToNotificationsAsync(String partnersId) async {
    try {
      return await firebaseMessaging.subscribeToTopic(partnersId);
    }
    on UnimplementedError catch (error, _) {
      debugPrint("subscribeToNotificationsAsync: Unimplemented error $error");
    }
  }

  /// Subscribe to notifications from partner, by subscribing to topic with [partnersId].
  Future<void> unsubscribeFromNotificationsAsync(String partnersId) async {
    try {
      return await firebaseMessaging.unsubscribeFromTopic(partnersId);
    }
    on UnimplementedError catch (error, _) {
      debugPrint("unsubscribeFromNotificationsAsync: Unimplemented error $error");
    }
  }

  bool _hasItBeenEnoughMillisecondsBetweenNudges(
          int milliSecondsSinceLastNudge) {
    int millisecondsSinceLastNudge = _getMillisecondsSinceLastNudge();
    int minMilliseconds = 1000;//_config.minimumMillisecondsBetweenNudges;
    bool result =
        millisecondsSinceLastNudge >=
            minMilliseconds;
    debugPrint("_hasItBeenEnoughMillisecondsBetweenNudges: $result for $milliSecondsSinceLastNudge, with minMilliseconds as $minMilliseconds");
    return result;
  }

  int _getMillisecondsSinceLastNudge() {
    var lastTimestamp = _prefsService.getInt(lastNudgeTimestampKey);
    lastTimestamp ??= 0;

    return _getCurrentTimeStamp() - lastTimestamp;
  }

  int _getCurrentTimeStamp() => clock.now().millisecondsSinceEpoch;

  String _getMinutesToWaitMessage(int milliSecondsSinceLastNudge) {
    int milliSecondsToWait =
        _config.minimumMillisecondsBetweenNudges - milliSecondsSinceLastNudge;
    Duration timeToWait = Duration(milliseconds: milliSecondsToWait);
    String errorMsg =
        'Wait ${_formatDuration(timeToWait)} minutes to nudge again.';
    return errorMsg;
  }

  String _formatDuration(Duration duration) =>
      "${duration.inMinutes}:${(duration.inSeconds.remainder(60))}";

  void _saveNudgeRequest(int requestedTimestampMilliseconds, String userId) {
    NotificationRequest request =
        NotificationRequest(requestedTimestampMilliseconds);
    _databaseService.mergeObjectAsync<NotificationRequest>(
        notificationDocumentPath(userId), request);
  }
}

/// Result of trying to send a nudge notification, with an error message if unsuccessful.
class NudgeResult {
  final bool successful;
  final String? errorMessage;

  NudgeResult(this.successful, {this.errorMessage});
}
