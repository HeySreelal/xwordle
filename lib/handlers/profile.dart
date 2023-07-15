import 'package:televerse/televerse.dart';
import 'package:xwordle/models/session.dart';

/// Handles the /profile command
MessageHandler profileHandler() {
  return (ctx) async {
    final user = ctx.session as WordleUser;
    await ctx.reply(
      "Hello <b>${user.name}</b>\n\n${profileDetails(user)}",
      parseMode: ParseMode.html,
    );
  };
}

/// Returns the profile details
String profileDetails(WordleUser user) {
  return "🎰 Total Games Played: <b>${user.totalGamesPlayed}</b>\n\n"
      "🎉 Total Games Won: <b>${user.totalWins}</b>\n\n"
      "🔥 Current Streak: <b>${user.streak}</b>\n\n"
      "🎆 Highest Streak: <b>${user.maxStreak}</b>\n\n"
      "💎 Win Percentage: <b>${(user.totalWins * 100 / user.totalGamesPlayed).toStringAsFixed(2)}</b>\n\n";
}
