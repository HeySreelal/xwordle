part of '../xwordle.dart';

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
    this.meaningCheckCount = 0,
  }) : next = next ?? launch.add(Duration(days: gameNo() + 1));

  /// Total winners
  int totalWinners;

  /// Total losers
  int totalLosers;

  /// Number of people who played
  int totalPlayed;

  /// Count of people who looked the meaning
  int meaningCheckCount;

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
      meaningCheckCount: map["meaningCheckCount"] ?? 0,
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
    save().ignore();
  }

  /// Save day to database
  Future<void> save() async {
    await WordleDB.saveToday(this);
  }

  /// Returns a map from the day
  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'index': index,
      'date': date.unixTime,
      'totalWinners': totalWinners,
      'totalLosers': totalLosers,
      'totalPlayed': totalPlayed,
      'dictionaryWord': dictionaryWord?.toJson(),
      'meaningCheckCount': meaningCheckCount,
      "next": next.unixTime,
    };
  }

  Future<void> resetCounters() async {
    totalPlayed = 0;
    totalWinners = 0;
    totalLosers = 0;
    meaningCheckCount = 0;
    await save();
  }
}
