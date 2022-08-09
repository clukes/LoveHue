import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/services/notification_service.dart';
import 'package:lovehue/utils/globals.dart';
import 'package:mockito/mockito.dart';

import '../mocker.mocks.dart';

void main() {
  late MockSharedPreferencesService mockPreferencesService;
  late NotificationService subject;
  final DateTime currentTime = DateTime(2020, 1, 1);
  final mockClock = Clock.fixed(currentTime);

  setUp(() {
    mockPreferencesService = MockSharedPreferencesService();
    subject = NotificationService(mockPreferencesService, clock: mockClock);
  });

  group("sendNudgeNotification", () {});

  group("canSendNudgeNotification", () {
    test('canSendNudgeNotification returns true when equal to minimum seconds since last send', () {
      String key = NotificationService.lastNudgeTimestampKey;
      int value = currentTime.millisecondsSinceEpoch - minimumMillisecondsBetweenNudges;
      when(mockPreferencesService.getInt(key)).thenReturn(value);

      // Act
      var result = subject.canSendNudgeNotification();

      verify(mockPreferencesService.getInt(key));
      expect(result, isTrue);
    });

    test('canSendNudgeNotification returns true when greater than minimum seconds since last send', () {
      String key = NotificationService.lastNudgeTimestampKey;
      int value = currentTime.millisecondsSinceEpoch - minimumMillisecondsBetweenNudges - 10;
      when(mockPreferencesService.getInt(key)).thenReturn(value);

      // Act
      var result = subject.canSendNudgeNotification();

      verify(mockPreferencesService.getInt(key));
      expect(result, isTrue);
    });

    test('canSendNudgeNotification returns false when less than minimum seconds since last send', () {
      String key = NotificationService.lastNudgeTimestampKey;
      int value = currentTime.millisecondsSinceEpoch - minimumMillisecondsBetweenNudges + 10;
      when(mockPreferencesService.getInt(key)).thenReturn(value);

      // Act
      var result = subject.canSendNudgeNotification();

      verify(mockPreferencesService.getInt(key));
      expect(result, isFalse);
    });
  });
}
