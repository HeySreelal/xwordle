part of '../xwordle.dart';

Handler startHandler({bool callback = false}) {
  return (Context ctx) async {
    // Answer if user reached here via callback
    if (callback) {
      await ctx.answerCallbackQuery();
    }

    // Most probably, user tapped the Inline Query Result Button :)
    if (ctx.args.isNotEmpty && ctx.args[0] == 'donate') {
      await donateHandler()(ctx);
      return;
    }

    // Get today's game and user profile
    final futures = [
      WordleDB.today(),
      WordleUser.init(ctx.id.id),
    ];
    final List<dynamic> result = await Future.wait(futures);
    WordleDay game = result[0];
    WordleUser user = result[1];

    // User is a first time visiter
    if (user.firstTime) {
      await doFirstTimeStuffs(ctx);
      return;
    }

    // Set user name
    if (user.name == WordleUser.defaultName && ctx.from != null) {
      user.name = ctx.from!.firstName;
    }

    // If the current game index is just the same as user's last game, you know they've already played
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
    user.tries = [];
    if (user.currentGame != game.index) {
      user.currentGame = game.index;
    }
    user.startTime = DateTime.now();

    Future.wait([
      user.save(),
      game.save(),
    ]).ignore();
  };
}

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
      "https://xwordle.web.app/assets/welcome.png",
    ),
    caption: MessageStrings.welcomeMessage,
    replyMarkup: InlineKeyboard().add("🎮 Start Game", "start"),
  );
}
