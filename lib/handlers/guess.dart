part of '../xwordle.dart';

/// Handles the user guesses
Handler guessHandler() {
  return (ctx) async {
    final (user, game) = await getUserAndGame(ctx.id.id);

    // If the user is not playing a game, tell them to start one
    if (!user.onGame) {
      await ctx.reply(random(MessageStrings.notOnGameMessages));
      return;
    }

    // If the user is playing a previous game, tell them to start a new one
    if (user.currentGame != game.index) {
      await ctx.reply(random(MessageStrings.notOnGameMessages));
      return;
    }

    final guess = ctx.message!.text!.trim().toLowerCase();
    if (guess.length != 5) {
      await ctx.reply(random(MessageStrings.mustBe5Letters));
      return;
    }

    final az = RegExp(r'[a-z]');

    if (guess.split('').any((l) => !az.hasMatch(l))) {
      await ctx.reply(random(MessageStrings.mustBeLetters));
      return;
    }

    if (!await Dictionary.existingWord(guess)) {
      await ctx.reply(random(MessageStrings.notValidWord));
      return;
    }

    final cw = game.word.toLowerCase();
    final gw = guess.toLowerCase();
    final result = getBoxes(cw, gw, user: user);

    user.tries.add(gw);
    final shareMsg = getShareMessage(
      cw,
      user.tries,
      game.index,
      user: user,
    );
    final shareUrl =
        "https://t.me/share/url?url=https://t.me/xwordlebot&text=${Uri.encodeComponent('Just finished a game at @xWordleBot. Here\'s my result:\n\n$shareMsg')}";

    if (cw == gw) {
      user.onGame = false;
      user.lastGame = game.index;
      user.streak++;
      user.totalWins++;
      user.endTime = DateTime.now();
      game.totalWinners++;
      if (user.streak > user.maxStreak) {
        user.maxStreak = user.streak;
      }
      if (user.tries.length == 1) {
        user.perfectGames++;
        await ctx.reply(random(MessageStrings.perfectGameMessages));
      }

      await ctx.reply(
        shareMsg,
        replyMarkup: InlineKeyboard().addUrl(
          "Share Your Result 📤",
          shareUrl,
        ),
      );

      await ctx.react("🎉", isBig: true);

      await ctx.reply(
        MessageStrings.guessedWordMessage.replaceAll(
          "{WORD}",
          game.word.toUpperCase(),
        ),
        parseMode: ParseMode.html,
        messageEffectId: "5046509860389126442",
      );
      await ctx.reply(
        "New word will be available in ${game.formattedDurationTillNext}",
      );
      await Future.delayed(Duration(seconds: 1));
      nudgeDonation(ctx);
    } else if (user.tries.length >= 6) {
      user.onGame = false;
      user.lastGame = game.index;
      user.streak = 0;
      final shareMsg = getShareMessage(
        cw,
        user.tries,
        game.index,
        user: user,
      );
      await ctx.reply(
        shareMsg,
        replyMarkup: InlineKeyboard().addUrl("Share 📤", shareUrl),
      );
      await ctx.reply(
        MessageStrings.lostGameMessage.replaceAll(
          '{WORD}',
          game.word.toUpperCase(),
        ),
        parseMode: ParseMode.html,
      );
      await ctx.reply(
        "New word will be available in ${game.formattedDurationTillNext}",
      );
      game.totalLosers++;
      user.endTime = DateTime.now();
    } else {
      await ctx.reply(result.join(" "));
      await ctx.reply(getGuessPrompt(user.tries.length));
      if (user.tries.length == 5 && user.hints.available) {
        await ctx.reply(
          "Stuck? You still have hints available! Use /hint to get a clue. ✨",
        );
      }
    }
    await user.save();
    await game.save();
  };
}

String eval(String word, String guess) {
  const correctSymbol = "+";
  const wrongSymbol = "-";
  const misplacedSymbol = "x";

  List<String> result = List.filled(5, wrongSymbol);
  List<bool> wordMatched = List.filled(5, false);
  List<bool> guessMatched = List.filled(5, false);

  // First pass: mark correct letters
  for (int i = 0; i < 5; i++) {
    if (guess[i] == word[i]) {
      result[i] = correctSymbol;
      wordMatched[i] = true;
      guessMatched[i] = true;
    }
  }

  // Second pass: mark misplaced letters
  for (int i = 0; i < 5; i++) {
    if (!guessMatched[i]) {
      for (int j = 0; j < 5; j++) {
        if (!wordMatched[j] && guess[i] == word[j]) {
          result[i] = misplacedSymbol;
          wordMatched[j] = true;
          guessMatched[i] = true;
          break;
        }
      }
    }
  }

  return result.join(",");
}

List<String> getBoxes(
  String word,
  String guess, {
  WordleUser? user,
}) {
  final shape = user?.hintShape ?? HintShape.circle;

  String list = eval(word, guess);
  list = list.replaceAll("+", shape.correct);
  list = list.replaceAll("-", shape.wrong);
  list = list.replaceAll("x", shape.misplaced);
  return list.split(",");
}

/// Creates the result grid for the user
List<String> resultGrid(
  String correct,
  List<String> guesses, {
  WordleUser? user,
}) {
  List<String> grid = List.generate(guesses.length, (index) {
    return getBoxes(correct, guesses[index], user: user).join(" ");
  });

  return grid;
}

/// Gets the shareable message for users' today's stats
String getShareMessage(
  String word,
  List<String> tries,
  int gameId, {
  WordleUser? user,
}) {
  final grid = resultGrid(word, tries, user: user);
  final msg =
      "#WordleBot $gameId - ${tries.length} / 6\n\n${grid.join('\n')}\n\n@xWordleBot";
  return msg;
}

/// Gets prompt for the user to guess the word
String getGuessPrompt(int tryCount) {
  switch (tryCount) {
    case 0:
      return "Shoot your first guess now...";
    case 1:
      return "Shoot your second guess now...";
    case 2:
      return "Shoot your third guess now...";
    case 3:
      return "Shoot your fourth guess now...";
    case 4:
      return "Shoot your fifth guess now...";
    case 5:
      return "And your last guess... 🎯";
    default:
      return "Shoot your guess now...";
  }
}
