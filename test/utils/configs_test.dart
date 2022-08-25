import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/utils/configs.dart';

void main() {
  group('NotificationsConfig', () {
    test('convertJson correctly converts json string', () {
      const testConfigJson = '''
      {
      "notificationCollectionPath": "/NudgeNotifications",
      "columnRequested": "requestedTimestampMilliseconds",
      "columnCompleted": "completedTimestampMilliseconds",
      "minimumMillisecondsBetweenNudges": 360000
      }
      ''';

      // Act
      var result = NotificationsConfig.convertJson(testConfigJson);

      expect(result.notificationCollectionPath, equals("/NudgeNotifications"));
      expect(result.columnRequested, equals("requestedTimestampMilliseconds"));
      expect(result.columnCompleted, equals("completedTimestampMilliseconds"));
      expect(result.minimumMillisecondsBetweenNudges, isA<int>());
      expect(result.minimumMillisecondsBetweenNudges, equals(360000));
    });
  });
}
