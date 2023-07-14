import 'package:televerse/televerse.dart';

/// The wordle session, keeps track of the current wordle of the user, and their progress
class WordleSession extends Session {
  /// The current game id
  int currentGame;

  /// The user id
  int userId;

  /// The date the user joined
  DateTime joinedDate;

  /// The last game id the user played
  int lastGame;

  /// The maximum streak the user has had
  int maxStreak;

  /// The user's name
  String name;

  /// Whether the user wants to be notified
  bool notify;

  /// Whether the user is currently playing a game
  bool onGame;

  /// The user's role
  String role;

  /// The user's current streak
  int streak;

  /// The total number of games the user has played
  int totalGamesPlayed;

  /// The total number of games the user has won
  int totalWins;

  /// The user's tries
  List<String> tries;

  /// Constructs a WordleSession
  WordleSession({
    this.currentGame = 0,
    this.userId = 0,
    this.lastGame = 0,
    this.maxStreak = 0,
    this.name = '',
    this.notify = false,
    this.onGame = false,
    this.role = 'Player',
    this.streak = 0,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.tries = const [],
    DateTime? joinedDate,
  }) : joinedDate = joinedDate ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() {
    return {
      'currentGame': currentGame,
      'userId': userId,
      'joinedDate': joinedDate.millisecondsSinceEpoch ~/ 1000,
      'lastGame': lastGame,
      'maxStreak': maxStreak,
      'name': name,
      'notify': notify,
      'onGame': onGame,
      'role': role,
      'streak': streak,
      'totalGamesPlayed': totalGamesPlayed,
      'totalWins': totalWins,
      'tries': tries,
    };
  }

  factory WordleSession.fromMap(Map<String, dynamic> map) {
    return WordleSession(
      currentGame: map['currentGame'] as int,
      userId: map['userId'] as int,
      joinedDate: DateTime.fromMillisecondsSinceEpoch(
        (map['joinedDate'] as int) * 1000,
      ),
      lastGame: map['lastGame'] as int,
      maxStreak: map['maxStreak'] as int,
      name: map['name'] as String,
      notify: map['notify'] as bool,
      onGame: map['onGame'] as bool,
      role: map['role'] as String,
      streak: map['streak'] as int,
      totalGamesPlayed: map['totalGamesPlayed'] as int,
      totalWins: map['totalWins'] as int,
      tries: map['tries'] as List<String>,
    );
  }

  static WordleSession init(int id) {
    final ses = Session.loadFromFile(WordleSession.fromMap, id: id);
    return ses ?? WordleSession(userId: id, name: 'Player', role: 'Player');
  }
}
