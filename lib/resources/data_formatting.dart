import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Formats a given timestamp like: 10 Jan 2022 (13:30).
String formatTimestamp(Timestamp timestamp) {
  return DateFormat.yMMMd()
      .addPattern("(HH:mm)")
      .format(timestamp.toDate().toLocal());
}
