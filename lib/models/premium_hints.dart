part of '../xwordle.dart';

class Hint {
  /// The count of hint let
  int left;

  /// The id o fthe last game where this hint is used.
  int? lastUsedGame;

  /// Creates the hint object
  Hint({
    this.lastUsedGame,
    this.left = 0,
  });

  factory Hint.fromMap(Map<String, dynamic>? map) {
    final hint = Hint();
    if (map != null) {
      hint.left = map["left"] ?? 0;
      hint.lastUsedGame = map["lastUsedGame"];
    }
    return hint;
  }

  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'lastUsedGame': lastUsedGame,
    };
  }

  bool get available => left > 0;
  bool get lowOnHint => left < 3;

  String leftCount() {
    if (lastUsedGame == gameNo()) {
      return "Used";
    }
    return left.toString();
  }
}

/// Premium Hints
class PremiumHints {
  /// New tag ends at this date;
  static DateTime noLongerNew = DateTime(2024, 8, 10);

  /// Number of extra attempts left for the user
  Hint extraAttempts;

  /// Number of letter exposal hints left for the user
  Hint letterReveals;

  /// (Metrics) Used hints
  int usedHintsCount;

  /// (Metrics) Hint purchase count
  int purchases;

  /// Constructs the Premium Hints object with the sepcified number of hints
  ///
  /// All hint types will be initialized to zero.
  PremiumHints({
    Hint? extraAttempts,
    Hint? letterReveals,
    this.purchases = 0,
    this.usedHintsCount = 0,
  })  : extraAttempts = extraAttempts ?? Hint(),
        letterReveals = letterReveals ?? Hint();

  /// Creates the Premium Hints object from the given nullable map.
  factory PremiumHints.fromMap(Map<String, dynamic>? map) {
    final hints = PremiumHints();
    if (map != null) {
      hints.extraAttempts = Hint.fromMap(map["extraAttempts"]);
      hints.letterReveals = Hint.fromMap(map["letterReveals"]);
      hints.purchases = map["purchases"] ?? 0;
      hints.usedHintsCount = map["usedHintsCount"] ?? 0;
    }
    return hints;
  }

  /// Converts to a JSON encodable Map
  Map<String, dynamic> toMap() {
    return {
      'extraAttempts': extraAttempts,
      'letterReveals': letterReveals,
      'purchases': purchases,
      'usedHintsCount': usedHintsCount,
    };
  }

  bool get available => extraAttempts.available || letterReveals.available;

  bool get lowOnHints => (extraAttempts.lowOnHint || letterReveals.lowOnHint);
}
