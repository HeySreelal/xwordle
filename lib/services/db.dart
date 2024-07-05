part of '../xwordle.dart';

/// Represents the database for the Wordle game.
class WordleDB {
  static WordleDay? _td;

  static Future<WordleDay> today() async {
    if (_td != null) {
      final dt = DateTime.now();
      if (dt.isBefore(_td!.next)) {
        return _td!;
      }
    }

    final game = await getToday();
    _td = game;
    return game;
  }

  static Future<WordleDay> getToday() async {
    final doc = await db.doc("game/today").get();
    final map = doc.data();
    return WordleDay.fromMap(map!);
  }

  static Future<List<WordleUser>> getUsers() async {
    final qs = await db.collection("players").get();
    return qs.docs.map((e) => WordleUser.fromMap(e.data())).toList();
  }

  static Future<void> saveToday(WordleDay day) async {
    await db.doc("game/today").update(day.toMap());
  }

  static Future<void> referralUpdate(int user, int referredBy) async {
    await db.doc("players/$user").update({
      "referredBy": referredBy,
    });
    await db.doc("players/$referredBy").update({
      "referralCount": FieldValue.increment(1),
      "referrals": FieldValue.arrayUnion([user])
    });
  }

  static Future<void> incrementUserCount() async {
    await db.doc("game/config").update({
      "totalPlayers": FieldValue.increment(1),
    });
  }

  static Future<void> incrementBlockedCount(int newBlocks) async {
    await db.doc("game/config").update({
      "blockedPlayers": FieldValue.increment(newBlocks),
    });
  }

  static Future<void> incrementHintsUsage(String type) async {
    final v = FieldValue.increment(1);
    final k = type == "use-letter" ? "letterRevealUsage" : "extraAttemptUsage";
    await db.doc("game/config").update({
      k: v,
    });
  }
}
