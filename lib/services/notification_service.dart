import 'package:clock/clock.dart';
import 'package:lovehue/services/shared_preferences_service.dart';
import 'package:lovehue/utils/globals.dart';

class NotificationService {
  static const String lastNudgeTimestampKey = "LastNudgeTimestamp";

  final SharedPreferencesService _prefsService;
  final Clock clock;
  NotificationService(this._prefsService, {this.clock = const Clock()});

  Future<NudgeResult> sendNudgeNotification() async {
    int milliSecondsSinceLastNudge = _getMillisecondsSinceLastNudge();
    if (!_hasItBeenEnoughMillisecondsBetweenNudges(
        milliSecondsSinceLastNudge)) {
      String errorMsg = _getMinutesToWaitMessage(milliSecondsSinceLastNudge);
      return NudgeResult(false, errorMessage: errorMsg);
    }

    // TODO: send nudge notification

    await _prefsService.setInt(lastNudgeTimestampKey, _getCurrentTimeStamp());

    return NudgeResult(true);
  }

  bool canSendNudgeNotification() => _hasItBeenEnoughMillisecondsBetweenNudges(
      _getMillisecondsSinceLastNudge());

  bool _hasItBeenEnoughMillisecondsBetweenNudges(
          int milliSecondsSinceLastNudge) =>
      _getMillisecondsSinceLastNudge() >= minimumMillisecondsBetweenNudges;

  int _getMillisecondsSinceLastNudge() {
    var lastTimestamp = _prefsService.getInt(lastNudgeTimestampKey);
    if (lastTimestamp == null) return 0;

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
}

class NudgeResult {
  final bool successful;
  final String? errorMessage;

  NudgeResult(this.successful, {this.errorMessage});
}
