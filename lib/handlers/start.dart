part of '../xwordle.dart';

const startPattern = "start";

Handler startHandler({bool callback = false}) {
  return (Context ctx) async {
    if (callback) {
      await ctx.answerCallbackQuery();
    }

    if (ctx.args.isNotEmpty && ctx.args[0] == 'donate') {
      await donateHandler()(ctx);
      return;
    }

    final (user, game) = await getUserAndGame(ctx.id.id);

    if (user.firstTime) {
      await handleFirstTimeUser(ctx, user);
      return;
    }

    _updateUserName(ctx, user);

    if (_isGameAlreadyPlayed(user, game)) {
      await _notifyGameAlreadyPlayed(ctx, game);
      nudgeDonation(ctx);
      return;
    }

    if (_isUserCurrentlyPlaying(user, game)) {
      await ctx.reply(MessageStrings.alreadyPlaying);
      return;
    }

    await _startNewGame(ctx, user, game);
  };
}

Future<void> handleFirstTimeUser(Context ctx, WordleUser user) async {
  await ctx.replyWithPhoto(
    InputFile.fromUrl("https://xwordle.web.app/assets/welcome.png"),
    caption: MessageStrings.welcomeMessage,
    replyMarkup: InlineKeyboard().add("🎮 Start Game", "start"),
  );
  WordleDB.incrementUserCount().ignore();

  if (ctx.args.isEmpty) return;

  final referrerId = int.tryParse(ctx.args[0]);
  if (referrerId == null) return;

  final referrerChat = ChatID(referrerId);

  await ctx.api.sendMessage(
    referrerChat,
    "🎉 ${ctx.from?.firstName} joined with your referral link.",
  );

  user.referrer = referrerId;
  user.save().ignore();

  final referredByUser = await WordleUser.init(referrerId);
  referredByUser.referrals.add(ctx.id.id);
  referredByUser.referralCount++;

  await handleReferralRewards(referredByUser, referrerChat);

  referredByUser.save().ignore();
}

Future<void> handleReferralRewards(
  WordleUser referredByUser,
  ChatID referrerChat,
) async {
  String rewardMessage = '';
  String spoilerMessage =
      "Keep inviting your friends. Who knows what surprise left for you!? 🎁👀";

  switch (referredByUser.referralCount) {
    case 3:
      referredByUser.hints.letterReveals.left += 2;
      rewardMessage = "Letter Reveal x2";
      break;
    case 6:
      referredByUser.hints.extraAttempts.left += 3;
      rewardMessage = "Extra Attempt x3";
      break;
    case 9:
      referredByUser.hints.addPlan(Plan.kickStartBundle);
      rewardMessage =
          "Kick Start Bundle (Letter Reveal x3 and one Extra Attempt)";
      break;
    case 15:
      referredByUser.hints.addPlan(Plan.advantagePack);
      rewardMessage =
          "Advantage Pack Combo (Letter Reveal x7 and Extra Attempt x3)";
      break;
    case 30:
      referredByUser.hints.addPlan(Plan.dominationKit);
      rewardMessage = "Domination Kit (Letter Reveal x15 and Extra Attempt x7)";
      break;
  }

  if (rewardMessage.isNotEmpty) {
    await api.sendMessage(
      referrerChat,
      "😎 Hey ${referredByUser.getName()}, I have a good news, just for you! You've unlocked the <tg-spoiler><b>$rewardMessage</b></tg-spoiler> power-up by achieving ${referredByUser.referralCount} referrals. 😎",
      messageEffectId: "5046509860389126442",
      parseMode: ParseMode.html,
    );
    await api.sendMessage(
      referrerChat,
      spoilerMessage,
      parseMode: ParseMode.html,
    );
  }
}

void _updateUserName(Context ctx, WordleUser user) {
  if (user.name == WordleUser.defaultName && ctx.from != null) {
    user.name = ctx.from!.firstName;
  }
}

bool _isGameAlreadyPlayed(WordleUser user, WordleDay game) {
  return game.index == user.lastGame;
}

Future<void> _notifyGameAlreadyPlayed(Context ctx, WordleDay game) async {
  final msg = random(MessageStrings.alreadyPlayed).replaceAll(
    "{DURATION}",
    game.formattedDurationTillNext,
  );
  await ctx.reply(msg);
}

bool _isUserCurrentlyPlaying(WordleUser user, WordleDay game) {
  return user.onGame && user.currentGame == game.index;
}

Future<void> _startNewGame(Context ctx, WordleUser user, WordleDay game) async {
  await ctx.reply(MessageStrings.letsStart, parseMode: ParseMode.html);

  if (user.hints.available &&
      (user.hints.usedHintsCount < 4 || shouldNudge())) {
    final message = user.hints.usedHintsCount == 0
        ? "🆕 Exciting news! You can now use /hint to get hints during the game."
        : "Reminder: You can use the /hint command to get some hints. 😉";

    await ctx.reply(message);
  }

  user.onGame = true;
  game.totalPlayed++;
  user.tries = [];

  if (user.currentGame != game.index) {
    user.currentGame = game.index;
  }

  user.startTime = DateTime.now();

  await Future.wait([user.save(), game.save()]);
}
