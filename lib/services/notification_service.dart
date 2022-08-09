import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lovehue/services/shared_preferences_service.dart';
import 'package:lovehue/utils/globals.dart';

class NotificationService {
  static const String lastNudgeTimestampKey = "LastNudgeTimestamp";

  final SharedPreferencesService _prefsService;
  NotificationService(this._prefsService);

  Future<NudgeResult> sendNudgeNotification() async {
    int secondsSinceLastNudge = _getSecondsSinceLastNudge();
    if (!_hasItBeenEnoughSecondsBetweenNudges(secondsSinceLastNudge)) {
      String errorMsg = _getMinutesToWaitMessage(secondsSinceLastNudge);
      return NudgeResult(false, errorMessage: errorMsg);
    }

    // TODO: send nudge notification

    _prefsService.setInt(lastNudgeTimestampKey, _getCurrentTimeStamp());

    return NudgeResult(true);
  }

  bool canSendNudgeNotification() =>
      _hasItBeenEnoughSecondsBetweenNudges(_getSecondsSinceLastNudge());

  bool _hasItBeenEnoughSecondsBetweenNudges(int secondsSinceLastNudge) =>
      secondsSinceLastNudge >= minimumSecondsBetweenNudges;

  int _getSecondsSinceLastNudge() {
    var lastTimestamp = _prefsService.getInt(lastNudgeTimestampKey);
    if (lastTimestamp == null) return 0;

    return _getCurrentTimeStamp() - lastTimestamp;
  }

  int _getCurrentTimeStamp() => Timestamp.now().seconds;

  String _getMinutesToWaitMessage(int secondsSinceLastNudge) {
    int secondsToWait = minimumSecondsBetweenNudges - secondsSinceLastNudge;
    Duration timeToWait = Duration(seconds: secondsToWait);
    String errorMsg =
        'Wait ${_formatDuration(timeToWait)} minutes to nudge again.';
    return errorMsg;
  }

  String _formatDuration(Duration duration) =>
      "${duration.inMinutes}:${(duration.inSeconds.remainder(60))}";
}

class NudgeResult {
  final bool successful;
  final String? errorMessage;

  NudgeResult(this.successful, {this.errorMessage});
}
