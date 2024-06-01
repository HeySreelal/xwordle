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

  static List<WordleUser> getUsers() {
    List<FileSystemEntity> files = Directory(".televerse/sessions").listSync();
    List<File> jsonFiles = files
        .where((e) => e is File && e.path.endsWith(".json"))
        .toList()
        .cast<File>();
    final users = jsonFiles.map((e) {
      final contents = e.readAsStringSync();
      return WordleUser.fromMap(jsonDecode(contents));
    }).toList();
    return users;
  }
}
