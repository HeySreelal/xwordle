import 'package:http/http.dart';
import 'package:televerse/televerse.dart';
import 'package:xwordle/config/consts.dart';
import 'package:xwordle/models/session.dart';
import 'package:xwordle/services/db.dart';
import 'package:xwordle/utils/utils.dart';

/// Handles the user guesses
MessageHandler guessHandler() {
  return (ctx) async {
    final user = ctx.session as WordleUser;
    final game = WordleDB.today;

    // If the user is not playing a game, tell them to start one
    if (!user.onGame) {
      await ctx.reply(random(MessageStrings.notOnGameMessages));
      return;
    }

    final guess = ctx.message.text!.trim().toLowerCase();
    if (guess.length != 5) {
      await ctx.reply(random(MessageStrings.mustBe5Letters));
      return;
    }

    final az = RegExp(r'[a-z]');

    if (guess.split('').any((l) => !az.hasMatch(l))) {
      await ctx.reply(random(MessageStrings.mustBeLetters));
      return;
    }

    if (!await existingWord(guess)) {
      await ctx.reply(random(MessageStrings.notValidWord));
      return;
    }

    final cw = game.word.toLowerCase();
    final gw = guess.toLowerCase();
    final result = getBoxes(cw, gw);

    user.tries.add(gw);
    final shareMsg = getShareableMessage(cw, user.tries, game.index);
    final shareUrl =
        "https://t.me/share/url?url=https://t.me/xwordlebot&text=${Uri.encodeComponent('Just finished a game at @xWordleBot. Here\'s my result:\n\n$shareMsg')}";

    if (cw == gw) {
      user.onGame = false;
      user.lastGame = game.index;
      user.streak++;
      user.totalWins++;
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
          "Share 📤",
          shareUrl,
        ),
      );
      await ctx.reply(
        "You guessed the word!\n\nThe word was <b>${game.word.toUpperCase()}</b>! 🚀",
      );
      await ctx.reply(
        "New word will be available in ${game.formattedDurationTillNext}",
      );
      user.tries = [];
    } else if (user.tries.length >= 6) {
      user.onGame = false;
      user.lastGame = game.index;
      user.streak = 0;
      final shareMsg = getShareableMessage(cw, user.tries, game.index);
      await ctx.reply(
        shareMsg,
        replyMarkup: InlineKeyboard().addUrl("Share 📤", shareUrl),
      );
      await ctx.reply(
        "You lost the game!\n\nThe word was <b>${game.word.toUpperCase()}</b>! 🔥",
        parseMode: ParseMode.html,
      );
      await ctx.reply(
        "New word will be available in ${game.formattedDurationTillNext}",
      );
      user.tries = [];
    } else {
      await ctx.reply(result.join(" "));
      await ctx.reply(getGuessPrompt(user.tries.length));
    }
    user.saveToFile();
  };
}

/// Confirms if the word exists in the dictionary
Future<bool> existingWord(String word) async {
  final response = await get(
    Uri.parse("https://api.dictionaryapi.dev/api/v2/entries/en/$word"),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

/// Creates the boxes for the given guess
List<String> getBoxes(String correct, String guess) {
  List<String?> boxes = [null, null, null, null, null];
  List<String?> letters = [...correct.split('')];
  List<String?> guessedLetters = [...guess.split('')];

  for (int i = 0; i < 5; i++) {
    if (letters[i] == guessedLetters[i]) {
      boxes[i] = "🟩";
      letters[i] = null;
      guessedLetters[i] = null;
    }
  }

  for (int i = 0; i < 5; i++) {
    if (letters[i] != null && guessedLetters.contains(letters[i])) {
      boxes[i] = "🟨";
      guessedLetters[guessedLetters.indexOf(letters[i])] = null;
    }
  }

  for (int i = 0; i < 5; i++) {
    if (boxes[i] == null) {
      boxes[i] = "⬛️";
    }
  }

  return boxes.cast<String>();
}

/// Creates the result grid for the user
List<String> resultGrid(String correct, List<String> guesses) {
  List<String> grid = List.generate(guesses.length, (index) {
    return getBoxes(correct, guesses[index]).join(" ");
  });

  return grid;
}

/// Gets the shareable message for users' today's stats
String getShareableMessage(String word, List<String> tries, int gameId) {
  final grid = resultGrid(word, tries);
  final msg =
      "#WordleBot $gameId - ${tries.length} / 6\n\n${grid.join('\n')}\n\n@xWordleBot";
  return msg;
}

/// Gets prompt for the user to guess the word
String getGuessPrompt(int tryCount) {
  if (tryCount == 1) {
    return "Shoot your first guess now...";
  } else if (tryCount == 2) {
    return "Shoot your second guess now...";
  } else if (tryCount == 3) {
    return "Shoot your third guess now...";
  } else if (tryCount == 4) {
    return "Shoot your fourth guess now...";
  } else if (tryCount == 5) {
    return "Shoot your fifth guess now...";
  } else if (tryCount == 6) {
    return "And your last guess... 🎯";
  } else {
    return "Shoot your guess now...";
  }
}
