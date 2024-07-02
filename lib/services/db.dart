part of '../xwordle.dart';

/// Represents the database for the Wordle game.
class WordleDB {
  static WordleDay get today {
    File file = File('day.json');
    if (!file.existsSync()) {
      throw Exception('day.json not found');
    }
    return WordleDay.fromMap(jsonDecode(file.readAsStringSync()));
  }

  static Future<List<WordleUser>> getUsers() async {
    final qs = await db.collection("players").get();
    return qs.docs.map((e) => WordleUser.fromMap(e.data())).toList();
  }
}
