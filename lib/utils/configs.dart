import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class NotificationsConfig {
  static const String configFileName = "notification_service.json";

  final String notificationCollectionPath;
  final String columnRequested;
  final String columnCompleted;
  final int minimumMillisecondsBetweenNudges;

  NotificationsConfig(this.notificationCollectionPath, this.columnRequested,
      this.columnCompleted, this.minimumMillisecondsBetweenNudges);

  static initialize() async {
    return _getJson();
  }

  static Future<NotificationsConfig> _getJson() async {
    return rootBundle.loadStructuredData<NotificationsConfig>(
        configFileName, (str) async => convertJson(str));
  }

  static NotificationsConfig convertJson(String jsonStr) =>
      NotificationsConfig.fromJson(jsonDecode(jsonStr));

  NotificationsConfig.fromJson(Map<String, dynamic> json)
      : notificationCollectionPath = json['notificationCollectionPath'],
        columnRequested = json['columnRequested'],
        columnCompleted = json['columnCompleted'],
        minimumMillisecondsBetweenNudges =
            json['minimumMillisecondsBetweenNudges'];
}
