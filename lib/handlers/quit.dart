import 'package:televerse/televerse.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/models/session.dart';
import 'package:xwordle/services/db.dart';

/// Handles the /quit command
///
/// This command is used to quit the current game.
MessageHandler quitHandler() {
  return (ctx) async {
    final game = WordleDB.today;
    final user = ctx.session as WordleUser;
    if (!user.onGame) {
      await ctx.reply(MessageStrings.notOnGame);
      return;
    }

    user.onGame = false;
    user.lastGame = game.index;
    user.streak = 0;
    user.tries = [];
    user.saveToFile();

    // Now let's tell the user today's word
    await ctx.reply(
      "Today's word is <b>${game.word}</b>.",
      parseMode: ParseMode.html,
    );
    await ctx.reply(
      "See ya with the next word in ${game.formattedDurationTillNext}",
    );
  };
}
