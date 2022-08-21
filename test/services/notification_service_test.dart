import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/services/notification_service.dart';
import 'package:lovehue/utils/globals.dart';
import 'package:mockito/mockito.dart';

import '../mocker.mocks.dart';

void main() {
  late MockSharedPreferencesService mockPreferencesService;
  late MockDatabaseService mockDatabaseService;
  late NotificationService subject;
  final DateTime currentTime = DateTime.now();
  final mockClock = Clock.fixed(currentTime);
  const String timestampKey = NotificationService.lastNudgeTimestampKey;
  const String userId = "1234";

  setUp(() {
    mockPreferencesService = MockSharedPreferencesService();
    mockDatabaseService = MockDatabaseService();
    subject = NotificationService(mockPreferencesService, mockDatabaseService,
        clock: mockClock);
  });

  group("sendNudgeNotification", () {
    Future _testUserIdCheck(String? userId) async {
      // Act
      var result = await subject.sendNudgeNotification(userId);

      expect(result, isNotNull);
      expect(result.successful, isFalse);
      expect(result.errorMessage, equals("No User Id."));
    }

    test('sendNudgeNotification returns error when userId is null or empty',
        () async => await _testUserIdCheck(null));

    test('sendNudgeNotification returns error when userId is empty',
        () async => await _testUserIdCheck(""));

    test(
        'sendNudgeNotification returns error when it hasnt been enough milliseconds between nudges',
        () async {
      int timeToWait = 100 * 1000; //100 seconds to millisecconds
      String timeToWaitFormatted = "1:40";
      int value = currentTime.millisecondsSinceEpoch -
          minimumMillisecondsBetweenNudges +
          timeToWait;
      when(mockPreferencesService.getInt(any)).thenReturn(value);

      // Act
      var result = await subject.sendNudgeNotification(userId);

      verify(mockPreferencesService.getInt(timestampKey));
      expect(result, isNotNull);
      expect(result.successful, isFalse);
      expect(result.errorMessage,
          equals("Wait $timeToWaitFormatted minutes to nudge again."));
    });

    test(
        'sendNudgeNotification sets int, stores timestamp and return true when it has been enough milliseconds between nudges',
        () async {
      var currentMilliseconds = currentTime.millisecondsSinceEpoch;

      int value = currentMilliseconds - minimumMillisecondsBetweenNudges - 10;
      when(mockPreferencesService.getInt(any)).thenReturn(value);
      when(mockPreferencesService.setInt(any, any))
          .thenAnswer((_) async => true);

      // Act
      var result = await subject.sendNudgeNotification(userId);

      verify(mockPreferencesService.getInt(timestampKey));
      verify(mockPreferencesService.setInt(timestampKey, currentMilliseconds));
      verify(mockDatabaseService.saveTimestampAsync(
          "nudgeNotifications/{userId}/requested",
          timestampKey,
          currentMilliseconds));
      expect(result, isNotNull);
      expect(result.successful, isTrue);
      expect(result.errorMessage, isNull);
    });
  });

  group("canSendNudgeNotification", () {
    test(
        'canSendNudgeNotification returns true when equal to minimum seconds since last send',
        () {
      int value =
          currentTime.millisecondsSinceEpoch - minimumMillisecondsBetweenNudges;
      when(mockPreferencesService.getInt(any)).thenReturn(value);

      // Act
      var result = subject.canSendNudgeNotification();

      verify(mockPreferencesService.getInt(timestampKey));
      expect(result, isTrue);
    });

    test(
        'canSendNudgeNotification returns true when greater than minimum seconds since last send',
        () {
      int value = currentTime.millisecondsSinceEpoch -
          minimumMillisecondsBetweenNudges -
          10;
      when(mockPreferencesService.getInt(any)).thenReturn(value);

      // Act
      var result = subject.canSendNudgeNotification();

      verify(mockPreferencesService.getInt(timestampKey));
      expect(result, isTrue);
    });

    test('canSendNudgeNotification returns true when lastTimestamp is null',
        () {
      when(mockPreferencesService.getInt(any)).thenReturn(null);

      // Act
      var result = subject.canSendNudgeNotification();

      verify(mockPreferencesService.getInt(timestampKey));
      expect(result, isTrue);
    });

    test(
        'canSendNudgeNotification returns false when less than minimum seconds since last send',
        () {
      int value = currentTime.millisecondsSinceEpoch -
          minimumMillisecondsBetweenNudges +
          10;
      when(mockPreferencesService.getInt(any)).thenReturn(value);

      // Act
      var result = subject.canSendNudgeNotification();

      verify(mockPreferencesService.getInt(timestampKey));
      expect(result, isFalse);
    });
  });
}
