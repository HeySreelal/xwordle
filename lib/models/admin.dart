part of '../xwordle.dart';

class AdminConfig {
  /// No of total blocked players
  int blockedPlayers;

  /// The release note.
  String releaseNote;

  /// Target user's type for the particular release note
  String targetPlayers;

  /// Total Players
  int totalPlayers;

  AdminConfig(
    this.blockedPlayers,
    this.releaseNote,
    this.targetPlayers,
    this.totalPlayers,
  );

  static Future<AdminConfig> get() async {
    final doc = await db.doc("game/config").get();
    return AdminConfig.fromMap(doc.data()!);
  }

  static Future<void> setReleaseNote(String note) async {
    await db.doc("game/config").update({
      "releaseNote": note,
    });
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'blockedPlayers': blockedPlayers,
      'releaseNote': releaseNote,
      'targetPlayers': targetPlayers,
      'totalPlayers': totalPlayers,
    };
  }

  factory AdminConfig.fromMap(Map<String, dynamic> map) {
    return AdminConfig(
      map['blockedPlayers'] as int,
      map['releaseNote'] as String,
      map['targetPlayers'] as String,
      map['totalPlayers'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory AdminConfig.fromJson(String source) =>
      AdminConfig.fromMap(json.decode(source) as Map<String, dynamic>);
}
