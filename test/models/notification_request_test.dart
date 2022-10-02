import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/models/notification_request.dart';

void main() {
  const int requested = 123456789;
  const int completed = 987654321;

  group('toMap', () {
    test('valid NotificationRequest should return map', () {
      final subject = NotificationRequest(requested,
          completedTimestampMilliseconds: completed);

      Map<String, Object?> expected = {
        'requestedTimestampMilliseconds': requested,
        'completedTimestampMilliseconds': completed
      };

      // Act
      Map<String, Object?> result = subject.toMap();

      expect(mapEquals(result, expected), isTrue);
    });
  });

  group('toMapIgnoreNulls', () {
    test('valid NotificationRequest should return map, excluding null values',
        () {
      final subject = NotificationRequest(requested);

      Map<String, Object?> expected = {
        'requestedTimestampMilliseconds': requested
      };

      // Act
      Map<String, Object?> result = subject.toMapIgnoreNulls();

      expect(mapEquals(result, expected), isTrue);
    });
  });
}
