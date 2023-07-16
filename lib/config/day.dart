import 'dart:convert';
import 'dart:io';

import 'package:xwordle/handlers/update.dart';
import 'package:xwordle/services/dict.dart';
import 'package:xwordle/utils/utils.dart';

/// This class represents a Wordle Day
class WordleDay {
  /// The word for the day
  String word;

  /// Current index of the word
  int index;

  /// The date of the day
  DateTime date;

  /// The date of next wordle
  DateTime next;

  /// Word meaning as Dictionary Word
  Word? dictionaryWord;

  /// Constructor
  WordleDay(
    this.word,
    this.index,
    this.date, {
    this.totalWinners = 0,
    this.totalLosers = 0,
    this.totalPlayed = 0,
    this.dictionaryWord,
    DateTime? next,
  }) : next = next ?? launch.add(Duration(days: gameNo() + 1));

  /// Total winners
  int totalWinners;

  /// Total losers
  int totalLosers;

  /// Number of people who played
  int totalPlayed;

  /// Returns a WordleDay from a map
  factory WordleDay.fromMap(Map<String, dynamic> map) {
    return WordleDay(
      map['word'],
      map['index'],
      DateTime.fromMillisecondsSinceEpoch(map['date'] * 1000),
      totalWinners: map['totalWinners'] ?? 0,
      totalLosers: map['totalLosers'] ?? 0,
      totalPlayed: map['totalPlayed'] ?? 0,
      dictionaryWord: map['dictionaryWord'] != null
          ? Word.fromJson(map['dictionaryWord'])
          : null,
    );
  }

  /// Returns the formatted duration till the next wordle
  String get formattedDurationTillNext {
    return DateUtil.getFormattedDuration(next);
  }

  /// Update the word
  WordleDay updateWord(String word) {
    return WordleDay(word, index, date);
  }

  set meaning(Word? word) {
    dictionaryWord = word;
    save();
  }

  /// Save day to day.json
  void save() {
    final file = File('day.json');
    if (!file.existsSync()) {
      file.createSync();
    }
    file.writeAsStringSync(jsonEncode(toMap()));
  }

  /// Returns a map from the day
  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'index': index,
      'date': date.millisecondsSinceEpoch ~/ 1000,
      'totalWinners': totalWinners,
      'totalLosers': totalLosers,
      'totalPlayed': totalPlayed,
      'dictionaryWord': dictionaryWord?.toJson(),
    };
  }

  void resetCounters() {
    totalPlayed = 0;
    totalWinners = 0;
    totalLosers = 0;
    save();
  }
}
