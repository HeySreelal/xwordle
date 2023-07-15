import 'dart:convert';
import 'dart:io';

import 'package:xwordle/utils/utils.dart';

/// This class represents a Wordle Day
class WordleDay {
  /// The word for the day
  final String word;

  /// Current index of the word
  final int index;

  /// The date of the day
  final DateTime date;

  /// Next day
  DateTime get next => date.add(Duration(days: 1));

  /// Constructor
  WordleDay(this.word, this.index, this.date);

  /// Returns a WordleDay from a map
  factory WordleDay.fromMap(Map<String, dynamic> map) {
    return WordleDay(
      map['word'],
      map['index'],
      DateTime.fromMillisecondsSinceEpoch(map['date'] * 1000),
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
    };
  }
}
