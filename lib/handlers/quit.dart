import 'package:televerse/televerse.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/models/session.dart';
import 'package:xwordle/services/db.dart';

/// Handles the /quit command
///
/// This command is used to quit the current game.
MessageHandler quitHandler() {
  return (ctx) async {
    final user = ctx.session as WordleUser;
    if (!user.onGame) {
      await ctx.reply(MessageStrings.notOnGame);
      return;
    }

    final keyboard = InlineKeyboard()
        .add("Yes, I quit.", "quit:yes")
        .row()
        .add("No, I don't.", "quit:no");

    await ctx.reply(
      "Are you sure you want to quit the game?",
      replyMarkup: keyboard,
    );
  };
}

/// The pattern used to match the callback query for the quit interaction
final quitPattern = RegExp(r"quit:(yes|no)");

/// Handles the callback query for the quit interaction
CallbackQueryHandler handleQuitInteraction() {
  return (ctx) async {
    final user = ctx.session as WordleUser;
    final game = WordleDB.today;
    final data = ctx.data!;
    bool quit = data == "quit:yes";

    await ctx.api.deleteMessage(ctx.id, ctx.message!.messageId);
    if (!quit) {
      await ctx.api.sendMessage(ctx.id, "Alright, let's continue.");
      return;
    }

    user.onGame = false;
    user.lastGame = game.index;
    user.streak = 0;
    user.tries = [];
    user.saveToFile();
    game.totalLosers++;
    game.save();

    // Now let's tell the user today's word
    await ctx.api.sendMessage(
      ctx.id,
      "Today's word is <b>${game.word}</b>.",
      parseMode: ParseMode.html,
    );
    await ctx.api.sendMessage(
      ctx.id,
      "See ya with the next word in ${game.formattedDurationTillNext}",
    );
  };
}
