part of '../xwordle.dart';

/// Handles the /quit command
///
/// This command is used to quit the current game.
Handler quitHandler() {
  return (ctx) async {
    final user = await WordleUser.init(ctx.id.id);
    if (!user.onGame) {
      await ctx.reply(MessageStrings.notOnGame);
      return;
    }

    final keyboard = InlineKeyboard()
        .add("Yes, I quit.", "quit:yes")
        .row()
        .add("No, I don't.", "quit:no");

    await ctx.reply(
      "Are you sure you want to quit the game? This will reset your streak.",
      replyMarkup: keyboard,
    );
  };
}

/// The pattern used to match the callback query for the quit interaction
final quitPattern = RegExp(r"quit:(yes|no)");

/// Handles the callback query for the quit interaction
Handler handleQuitInteraction() {
  return (ctx) async {
    ctx.answerCallbackQuery().ignore();
    final (user, game) = await getUserAndGame(ctx.id.id);
    final data = ctx.callbackQuery!.data!;
    bool quit = data == "quit:yes";

    await ctx.editMessageText(
      "✅ Quit confirmed.",
      replyMarkup: InlineKeyboard(),
    );
    if (!quit) {
      await ctx.reply("Alright, let's continue.");
      return;
    }

    user.onGame = false;
    user.lastGame = game.index;
    user.streak = 0;
    user.tries = [];
    await user.save();
    game.totalLosers++;
    await game.save();

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
