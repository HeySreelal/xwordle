import 'package:dart_firebase_admin/firestore.dart';
import 'package:xwordle/xwordle.dart';

int timestampToDateTime(int seconds, int nanoseconds) {
  // Firestore Timestamp is in seconds since the Unix epoch and nanoseconds.
  // Dart DateTime is in microseconds since the Unix epoch.

  // Convert nanoseconds to microseconds
  int microseconds = nanoseconds ~/ 1000;

  // Convert seconds to milliseconds and add microseconds to get total microseconds
  int totalMicroseconds = (seconds * 1000000) + microseconds;

  // Create DateTime object from microseconds since epoch
  DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(totalMicroseconds);

  return dateTime.millisecondsSinceEpoch ~/ 1000;
}

void main(List<String> args) async {
  final qs = await db.collection("players").get();
  int i = 0;
  while (i < qs.docs.length) {
    final data = qs.docs[i].data();
    final x = data["joinedDate"] as Timestamp;
    data["joinedDate"] = timestampToDateTime(x.seconds, x.nanoseconds);
    await qs.docs[i].ref.update(data);
    i++;
  }
}
