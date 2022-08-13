import 'package:flutter_test/flutter_test.dart';
import 'package:lovehue/services/shared_preferences_service.dart';
import 'package:mockito/mockito.dart';

import '../mocker.mocks.dart';

void main() {
  late MockSharedPreferences mockPreferences;
  late SharedPreferencesService subject;

  setUp(() {
    mockPreferences = MockSharedPreferences();
    subject = SharedPreferencesService(mockPreferences);
  });

  test('setInt calls preferences setInt', () {
    when(mockPreferences.setInt(any, any)).thenAnswer((_) async => false);

    String key = "Test";
    int value = 10;

    // Act
    subject.setInt(key, value);

    verify(mockPreferences.setInt(key, value));
  });

  test('getInt calls preferences getInt', () {
    when(mockPreferences.getInt(any)).thenReturn(null);

    String key = "Test";

    // Act
    subject.getInt(key);

    verify(mockPreferences.getInt(key));
  });
}
