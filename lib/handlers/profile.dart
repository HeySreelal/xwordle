part of '../xwordle.dart';

/// Handles the /profile command
Handler profileHandler() {
  return (ctx) async {
    final user = await WordleUser.init(ctx.id.id);
    await ctx.reply(
      "Hello <b>${user.name}</b>\n\n${profileDetails(user)}",
      parseMode: ParseMode.html,
    );
    nudgeDonation(ctx);
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
