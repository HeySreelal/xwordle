part of '../xwordle.dart';

/// The wordle hint shape, used to display the hint
enum HintShape {
  circle._("🟢", "⚫️", "🟡"),
  square._("🟩", "⬛️", "🟨"),
  heart._("💚", "🖤", "💛"),
  ;

  final String correct;
  final String wrong;
  final String misplaced;

  const HintShape._(this.correct, this.wrong, this.misplaced);

  String get name => toString().split('.').last;

  static HintShape fromName(String name) {
    return HintShape.values.firstWhere(
      (e) => e.name == name,
      orElse: () => HintShape.circle,
    );
  }

  static HintShape fromText(String text) {
    return HintShape.values.firstWhere(
      (e) => text.toLowerCase().contains(e.name.toLowerCase()),
      orElse: () => HintShape.circle,
    );
  }

  String get shapes {
    return "$correct $misplaced $wrong";
  }

  static HintShape random() {
    return HintShape.values[Random().nextInt(HintShape.values.length)];
  }

  static const circleText = "Circle 🟢";
  static const squareText = "Square 🟨";
  static const heartText = "Heart 🖤";
  static const randText = "Random 🎲";
}

/// The wordle session, keeps track of the current wordle of the user, and their progress
class WordleUser {
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

  /// The number of perfect games the user has had
  int perfectGames;

  /// Hint shape of user's preference
  HintShape hintShape;

  /// Whether the user is opted out for broadcast messages
  bool optedOutOfBroadcast;

  /// Constructs a WordleSession
  WordleUser({
    this.currentGame = 0,
    this.userId = 0,
    this.lastGame = 0,
    this.maxStreak = 0,
    this.name = '',
    this.notify = false,
    this.onGame = false,
    this.role = defaultName,
    this.streak = 0,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.tries = const [],
    this.perfectGames = 0,
    DateTime? joinedDate,
    HintShape? hintShape,
    this.optedOutOfBroadcast = false,
  })  : joinedDate = joinedDate ?? DateTime.now(),
        hintShape = hintShape ?? HintShape.circle;

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
      'perfectGames': perfectGames,
      'hintShape': hintShape.name,
      'optedOutOfBroadcast': optedOutOfBroadcast,
    };
  }

  factory WordleUser.fromMap(Map<String, dynamic> map) {
    return WordleUser(
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
      role: map['role'] ?? defaultName,
      streak: map['streak'] as int,
      totalGamesPlayed: map['totalGamesPlayed'] as int,
      totalWins: map['totalWins'] as int,
      tries: map['tries'].cast<String>(),
      perfectGames: map['perfectGames'] ?? 0,
      hintShape: HintShape.fromName(map['hintShape'] ?? 'circle'),
      optedOutOfBroadcast: map['optedOutOfBroadcast'] ?? false,
    );
  }

  static const String defaultName = 'Player';

  static WordleUser? loadFromFile(
    WordleUser Function(Map<String, dynamic>) fromMap, {
    int? id,
  }) {
    if (id == null) return null;

    final f = File(".sessions/$id.json");
    if (!f.existsSync()) return null;
    final content = f.readAsStringSync();
    return fromMap(jsonDecode(content));
  }

  void saveToFile() {
    File(".sessions/$userId.json").writeAsStringSync(toJson().toString());
  }

  static WordleUser init(int id) {
    final ses = loadFromFile(WordleUser.fromMap, id: id);
    return ses ?? WordleUser(userId: id, name: defaultName, role: defaultName);
  }

  bool hasPlayedInLast4Days() {
    return (gameNo() - lastGame) < 4;
  }

  void resetProfile([String? n]) {
    currentGame = 0;
    lastGame = lastGame;
    maxStreak = 0;
    name = n ?? defaultName;
    notify = true;
    onGame = false;
    role = defaultName;
    streak = 0;
    totalGamesPlayed = 0;
    totalWins = 0;
    tries = [];
    perfectGames = 0;
    hintShape = HintShape.circle;
    optedOutOfBroadcast = false;
    saveToFile();
  }
}
