part of '../xwordle.dart';

Future<void> doFirstTimeStuffs(Context ctx) async {
  if (ctx.args.isNotEmpty) {
    final referrer = int.tryParse(ctx.args[0]);
    if (referrer != null) {
      ctx.api
          .sendMessage(
            ChatID(referrer),
            "🎉 ${ctx.from?.firstName} joined with your referral link.",
          )
          .ignore();
      WordleDB.referralUpdate(ctx.id.id, referrer).ignore();
    }
  }
  WordleDB.incrementUserCount().ignore();
  await ctx.replyWithPhoto(
    InputFile.fromUrl(
      "https://televerse-space.web.app/assets/wordle-welcome.png",
    ),
    caption: MessageStrings.welcomeMessage,
    replyMarkup: InlineKeyboard().add("🎮 Start Game", "start"),
  );
}

Handler startHandler({bool callback = false}) {
  return (Context ctx) async {
    if (callback) {
      await ctx.answerCallbackQuery();
    }
    if (ctx.args.isNotEmpty && ctx.args[0] == 'donate') {
      await donateHandler()(ctx);
      return;
    }
    final game = await WordleDB.today();
    final user = await WordleUser.init(ctx.id.id);
    if (user.firstTime) {
      await doFirstTimeStuffs(ctx);
      return;
    }
    if (user.name == WordleUser.defaultName && ctx.from != null) {
      user.name = ctx.message!.from!.firstName;
    }

    if (game.index == user.lastGame) {
      final msg = random(MessageStrings.alreadyPlayed).replaceAll(
        "{DURATION}",
        game.formattedDurationTillNext,
      );
      await ctx.reply(msg);
      nudgeDonation(ctx);
      return;
    }

    /// If the user is already playing a game, tell them to finish it first
    if (user.onGame && user.currentGame == game.index) {
      await ctx.reply(MessageStrings.alreadyPlaying);
      return;
    }

    /// Let's start a new game
    await ctx.reply(MessageStrings.letsStart, parseMode: ParseMode.html);
    user.onGame = true;
    game.totalPlayed++;
    if (user.currentGame != game.index) {
      user.currentGame = game.index;
      user.tries = [];
      user.totalGamesPlayed++;
    }
    user.save();
    game.save();
  };
}
