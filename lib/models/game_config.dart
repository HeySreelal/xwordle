part of '../xwordle.dart';

class GameConfig {
  int blockedPlayers;

  int extraAttemptUsage;

  int letterRevealUsage;

  String releaseNote;

  int totalInvites;

  int totalPlayers;

  GameConfig({
    required this.blockedPlayers,
    required this.extraAttemptUsage,
    required this.letterRevealUsage,
    required this.releaseNote,
    required this.totalInvites,
    required this.totalPlayers,
  });

  factory GameConfig.fromCloud(Map<String, dynamic> map) {
    return GameConfig(
      blockedPlayers: map["blockedPlayers"],
      extraAttemptUsage: map["extraAttemptUsage"],
      letterRevealUsage: map["letterRevealUsage"],
      releaseNote: map["releaseNote"],
      totalInvites: map["totalInvites"],
      totalPlayers: map["totalPlayers"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "blockedPlayers": blockedPlayers,
      "extraAttemptUsage": extraAttemptUsage,
      "letterRevealUsage": letterRevealUsage,
      "releaseNote": releaseNote,
      "totalInvites": totalInvites,
      "totalPlayers": totalPlayers,
    };
  }

  GameConfig copyWith({
    int? blockedPlayers,
    int? extraAttemptUsage,
    int? letterRevealUsage,
    String? releaseNote,
    int? totalInvites,
    int? totalPlayers,
  }) {
    return GameConfig(
      blockedPlayers: blockedPlayers ?? this.blockedPlayers,
      extraAttemptUsage: extraAttemptUsage ?? this.extraAttemptUsage,
      letterRevealUsage: letterRevealUsage ?? this.letterRevealUsage,
      releaseNote: releaseNote ?? this.releaseNote,
      totalInvites: totalInvites ?? this.totalInvites,
      totalPlayers: totalPlayers ?? this.totalPlayers,
    );
  }
}
