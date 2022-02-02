import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestamp) {
  return DateFormat.yMMMd().addPattern("(HH:mm)").format(timestamp.toDate().toLocal());
}
