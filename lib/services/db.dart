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

  @Deprecated(
    "This shit has been deprecated. Use the `getAllUsers()` method instead.",
  )
  static Future<List<WordleUser>> getUsers() async {
    final qs = await db.collection("players").get();
    return qs.docs.map((e) => WordleUser.fromMap(e.data())).toList();
  }

  static Future<List<int>> notifyMePeople() async {
    final doc = await db.doc("game/subscribers").get();
    final data = doc.data()!;
    return (data["users"] as List).cast<int>();
  }

  static Future<void> saveToday(WordleDay day) async {
    await db.doc("game/today").update(day.toMap());
  }

  static Future<void> incrementUserCount({
    bool isInvited = false,
  }) async {
    await db.doc("game/config").update({
      "totalPlayers": FieldValue.increment(1),
      if (isInvited) "totalInvites": FieldValue.increment(1),
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

  static Future<GameConfig> getGameConfig() async {
    final doc = await db.doc("game/config").get();
    final config = GameConfig.fromCloud(doc.data()!);
    return config;
  }

  static Future<void> updateNotifyList(List<int> users) async {
    try {
      await db.doc("game/subscribers").update({
        "users": users,
      });
    } catch (_) {}
  }

  static Future<List<int>> getAllUsers() async {
    final doc = await db.doc("game/all-players").get();
    return ((doc.data()!)["users"] as List).cast<int>();
  }

  static Future<void> addNewUser(int user) async {
    try {
      await db.doc("game/subscribers").update({
        "users": FieldValue.arrayUnion([user]),
      });
      await db.doc("game/all-players").update({
        "users": FieldValue.arrayUnion([user]),
      });
    } catch (_) {}
  }

  static Future<void> toggleNotification(int user, bool on) async {
    try {
      await db.doc("game/subscribers").update({
        "users":
            on ? FieldValue.arrayUnion([user]) : FieldValue.arrayRemove([user]),
      });
    } catch (_) {}
  }
}
