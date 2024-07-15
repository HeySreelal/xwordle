part of '../xwordle.dart';

/// The wordle session, keeps track of the current wordle of the user, and their progress
class WordleUser {
  /// The current game id
  int currentGame;

  /// The user id
  int id;

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

  /// Whether the user is a first time visitor
  bool firstTime;

  /// Game start time
  DateTime? startTime;

  /// Game end time
  DateTime? endTime;

  /// Points
  int points;

  /// Premium Hints available to the user
  PremiumHints hints;

  /// Referrer's User ID
  int? referrer;

  /// Referral Count
  int referralCount;

  /// The ids of the people the current person has invited
  List<int> referrals;

  /// A flag indicating whether the user has already subscribed to @Xooniverse
  /// to get redeem the order.
  bool hasClaimedXooniverseOffer;

  /// Constructs a WordleSession
  WordleUser({
    this.currentGame = 0,
    this.id = 0,
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
    this.firstTime = false,
    this.endTime,
    this.startTime,
    this.points = 0,
    PremiumHints? hints,
    this.referralCount = 0,
    List<int>? referrals,
    this.referrer,
    this.hasClaimedXooniverseOffer = false,
  })  : joinedDate = joinedDate ?? DateTime.now(),
        hintShape = hintShape ?? HintShape.circle,
        hints = hints ?? PremiumHints(),
        referrals = referrals ?? [];

  Map<String, dynamic> toJson() {
    return {
      'currentGame': currentGame,
      'id': id,
      'joinedDate': joinedDate.unixTime,
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
      'startTime': startTime?.unixTime,
      'endTime': endTime?.unixTime,
      'points': points,
      'hints': hints.toMap(),
      'referralCount': referralCount,
      'referrals': referrals,
      'referrer': referrer,
      'hasClaimedXooniverseOffer': hasClaimedXooniverseOffer,
    };
  }

  factory WordleUser.fromMap(Map<String, dynamic> map) {
    return WordleUser(
      currentGame: map['currentGame'] as int,
      id: map['id'] as int,
      joinedDate: (map['joinedDate'] as int).toDateTime(),
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
      startTime: (map["startTime"] as int?)?.toDateTime(),
      endTime: (map["endTime"] as int?)?.toDateTime(),
      points: map['points'] ?? 0,
      hints: PremiumHints.fromMap(map['hints']),
      referralCount: map["referralCount"] ?? 0,
      referrals: map["referrals"]?.cast<int>(),
      referrer: map["referrer"],
      hasClaimedXooniverseOffer: map["hasClaimedXooniverseOffer"] ?? false,
    );
  }

  static const String defaultName = 'Player';

  String get docId => "players/$id";

  Future<void> save() async {
    if (firstTime) {
      await db.doc(docId).set(toJson());
    } else {
      await db.doc(docId).update(toJson());
    }
  }

  static Future<WordleUser> init(int id) async {
    final doc = await db.doc("players/$id").get();
    if (!doc.exists) {
      final user = WordleUser(id: id, firstTime: true);
      user.save().ignore();
      return user;
    }
    return WordleUser.fromMap(doc.data()!);
  }

  bool hasPlayedInLast4Days() {
    return (gameNo() - lastGame) < 4;
  }

  Future<void> resetProfile([String? n]) async {
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
    startTime = null;
    endTime = null;
    points = 0;
    await save();
  }

  bool get hasHintsAvailable {
    return hints.available;
  }

  String getName() {
    if (name.isEmpty) {
      return WordleUser.defaultName;
    }
    return name;
  }
}
