import 'dart:convert';
import 'dart:io';

import 'package:xwordle/config/day.dart';

/// Represents the database for the Wordle game.
class WordleDB {
  static WordleDay get today {
    File file = File('day.json');
    if (!file.existsSync()) {
      throw Exception('day.json not found');
    }
    return WordleDay.fromMap(jsonDecode(file.readAsStringSync()));
  }
}
