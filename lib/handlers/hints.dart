part of '../xwordle.dart';

// Hints Patterns
const hintsGetPattern = "hints:get";
const useLetterPattern = "hints:use-letter";
const useAttemptPattern = "hints:use-attempt";
const hintsIndividual = "hints:individual";
const buykickstart = "buy:kickstart";
const buyadvantage = "buy:advantage";
const buydomination = "buy:domination";
const letterreveal = "letterreveal";
const extraattempt = "extraattempt";
final letterRevealPattern = RegExp(r"letterreveal:(.*)");
final extraattemptPattern = RegExp(r"extraattempt:(.*)");
const backToPricingPattern = "back:pricing";

Handler hintsHandler() {
  return (ctx) async {
    final user = await WordleUser.init(ctx.id.id);
    bool showNewTag = shouldShowNewTag(user);

    if (!user.onGame) {
      await sendHintInfo(ctx, user, showNewTag);
    } else {
      await sendHintUsage(ctx, user, showNewTag);
    }
  };
}

bool shouldShowNewTag(WordleUser user) {
  return DateTime.now().isBefore(PremiumHints.noLongerNew) &&
      user.hints.usedHintsCount < 3;
}

Future<void> sendHintInfo(Context ctx, WordleUser user, bool showNewTag) async {
  final getMoreBoard =
      InlineKeyboard().add("🌟 Get more Hints", hintsGetPattern);
  await ctx.reply(
    (showNewTag ? "🆕 " : "") + getHintInfoMessage(user.hints),
    replyMarkup: getMoreBoard,
  );

  final String referralInfo = """
👫 You can also earn free hints by inviting friends! Achieve the milestones to earn some cool reward packs.

Send /invite to get your referral link.
""";

  await ctx.reply(referralInfo);
}

Future<void> sendHintUsage(
    Context ctx, WordleUser user, bool showNewTag) async {
  final useHintBoard = InlineKeyboard()
      .add(
        "Letter Reveal (${user.hints.letterReveals.leftCount()})",
        useLetterPattern,
      )
      .add(
        "Extra Attempt (${user.hints.extraAttempts.leftCount()})",
        useAttemptPattern,
      )
      .row()
      .add(
        "🌟 Get more Hints",
        hintsGetPattern,
      );

  await ctx.reply(
    "${showNewTag ? "🆕 " : ""}You can use one of each hint once in a game.\n\n"
    "- <b>Extra Attempt</b>: Guess a word without including it on your 6 tries.\n"
    "- <b>Letter Reveal</b>: Reveal a letter from the actual word.\n\n"
    "Which hint are you choosing to use now?",
    replyMarkup: useHintBoard,
    parseMode: ParseMode.html,
  );
}

String getHintInfoMessage(PremiumHints hints) {
  final String greeting = "Hints for Wordle! 🌟";
  final String hintInfo =
      "Hints are special features that can help you in your Wordle game. "
      "You can use hints to reveal letters or get extra attempts to guess the word.";

  final String hintBalance = """
Here is your current hint balance:
- Extra Attempts: ${hints.extraAttempts.left}
- Letter Reveals: ${hints.letterReveals.left}
""";

  final String lowHintPrompt = hints.lowOnHints
      ? "\nYou have a low number of hints left. Consider purchasing more hints by clicking the button below."
      : "";

  return "$greeting\n\n$hintInfo\n\n$hintBalance$lowHintPrompt";
}

Handler hintsGetHandler({bool shouldEdit = false}) {
  const picUrl = "https://xwordle.web.app/assets/hints.png";

  return (ctx) async {
    ctx.answerCallbackQuery().ignore();
    final board = buildInlineKeyboard();

    if (shouldEdit) {
      await editMessageCaption(ctx, MessageStrings.pricingMessage, board);
    } else {
      await replyWithPhoto(ctx, picUrl, MessageStrings.pricingMessage, board);
    }
  };
}

InlineKeyboard buildInlineKeyboard() {
  return InlineKeyboard()
      .add("Get Individual Hints 🌟", hintsIndividual)
      .row()
      .add("⭐️ Get Wordle Kickstart Bundle", buykickstart)
      .row()
      .add("🔥 Get Wordle Advantage Pack", buyadvantage)
      .row()
      .add("✨ Get Wordle Domination Kit", buydomination);
}

Future<void> editMessageCaption(
  Context ctx,
  String caption,
  InlineKeyboard board,
) async {
  await ctx.editMessageCaption(
    caption: caption,
    parseMode: ParseMode.html,
    replyMarkup: board,
  );
}

Future<void> replyWithPhoto(
  Context ctx,
  String photoUrl,
  String caption,
  InlineKeyboard board,
) async {
  await ctx.replyWithPhoto(
    InputFile.fromUrl(photoUrl),
    caption: caption,
    parseMode: ParseMode.html,
    replyMarkup: board,
  );
}

Handler hintsIndividualHandler() {
  final board = InlineKeyboard()
      .add("Letter Reveal - ⭐️ 35", "$letterreveal:1")
      .row()
      .add("x1", "$letterreveal:1")
      .add("x3", "$letterreveal:3")
      .add("x5", "$letterreveal:5")
      .row()
      .add("Extra Attempt - ⭐️ 75", "$extraattempt:1")
      .row()
      .add("x1", "$extraattempt:1")
      .add("x3", "$extraattempt:3")
      .add("x5", "$extraattempt:5")
      .row()
      .add("⏪ Go back", backToPricingPattern);

  return (ctx) async {
    ctx.answerCallbackQuery().ignore();
    await ctx.editMessageCaption(
      caption: MessageStrings.individualPricing,
      replyMarkup: board,
      parseMode: ParseMode.html,
    );
  };
}

Handler buyHandler(String pattern) {
  return (ctx) async {
    ctx.answerCallbackQuery().ignore();
    final data = ctx.callbackQuery!.data!;

    Plan plan;

    if (pattern == letterreveal || pattern == extraattempt) {
      plan = Plan.all.firstWhere((e) => e.payload == data);
    } else {
      plan = Plan.all.firstWhere((e) => e.payload == pattern);
    }

    await ctx.sendInvoice(
      title: plan.title,
      description: plan.description,
      payload: plan.payload,
      currency: "XTR",
      prices: [
        LabeledPrice(label: "Buy Now", amount: plan.amount),
      ],
    );
  };
}

Handler handleSuccessPaymentForHints(String payload) {
  final plan = Plan.all.singleWhere((e) => e.payload == payload);

  return (ctx) async {
    final successfulPayment = ctx.msg?.successfulPayment;
    final user = await WordleUser.init(ctx.id.id);

    if (successfulPayment != null) {
      await _savePaymentData(ctx, successfulPayment, plan, user);
    }

    user.hints.addPlan(plan);
    await user.save();

    final text = _generateSuccessMessage(plan, user);
    await ctx.reply(
      text,
      parseMode: ParseMode.html,
      messageEffectId: "5046509860389126442",
    );
  };
}

Future<void> _savePaymentData(
  Context ctx,
  SuccessfulPayment successfulPayment,
  Plan plan,
  WordleUser user,
) async {
  db
      .doc(
          "players/${ctx.id.id}/payments/${successfulPayment.telegramPaymentChargeId}")
      .set({
    "successful_payment": successfulPayment.toJson(),
    "plan": plan.toMap(),
    "date": DateTime.now().unixTime,
    "user": user.id,
  }).ignore();
}

String _generateSuccessMessage(Plan plan, WordleUser user) {
  return """
You have successfully activated <b>${plan.title}</b> 🎉.\n\n
Here is your current hint balance:
- Extra Attempts: ${user.hints.extraAttempts.left}
- Letter Reveals: ${user.hints.letterReveals.left}

Start a new game and use the /hint command to access helpful power-ups. ⚡️
""";
}

(int, String) revealOptimalLetter(String word, List<String> tries) {
  // Create a set to track revealed correct positions
  Set<int> revealedPositions = {};

  // Iterate through the tries and track the correct positions
  for (String guess in tries) {
    for (int i = 0; i < word.length; i++) {
      if (guess[i] == word[i]) {
        revealedPositions.add(i);
      }
    }
  }

  // Try to find a letter that is in the word but not in the correct position
  for (String guess in tries) {
    for (int i = 0; i < word.length; i++) {
      if (guess[i] != word[i] && !revealedPositions.contains(i)) {
        return (i + 1, word[i]);
      }
    }
  }

  // If no such letter is found, find an unrevealed letter
  for (int i = 0; i < word.length; i++) {
    if (!revealedPositions.contains(i)) {
      return (i + 1, word[i]);
    }
  }

  // If all letters are revealed or no optimal letter is found, return a random letter
  Random random = Random();
  int i = random.nextInt(word.length);
  return (i + 1, word[i]);
}

Handler useHintHandler() {
  return (ctx) async {
    final user = await WordleUser.init(ctx.id.id);
    final data = ctx.callbackQuery!.data!.split(":")[1];
    final game = gameNo();
    final currentWord = getWord(game);

    if (data == "use-letter") {
      await _handleUseLetter(ctx, user, game, currentWord);
    } else if (data == "use-attempt") {
      await _handleUseAttempt(ctx, user, game, currentWord);
    }

    await _updateUserHints(user, data);
    _showHintOptions(ctx, user).ignore();
    ctx.answerCallbackQuery().ignore();
  };
}

Future<void> _handleUseLetter(
  Context ctx,
  WordleUser user,
  int game,
  String currentWord,
) async {
  if (user.hints.letterReveals.lastUsedGame == game) {
    await ctx.answerCallbackQuery(
      text: "You have already used this power-up for the current game. 🫣",
      showAlert: true,
    );
    return;
  }

  final msg = await ctx.reply("Give me a second to think... 🤔💭");
  final (index, letter) = revealOptimalLetter(currentWord, user.tries);
  await api.deleteMessage(ctx.id, msg.messageId);
  await ctx.reply(
    "Here we go! 🫣 <tg-spoiler>The ${index}th letter is $letter.</tg-spoiler>. Time for your guesses.",
    parseMode: ParseMode.html,
  );

  user.hints.letterReveals.left--;
  user.hints.letterReveals.lastUsedGame = game;
  user.hints.usedHintsCount++;
}

Future<void> _handleUseAttempt(
  Context ctx,
  WordleUser user,
  int game,
  String currentWord,
) async {
  if (user.hints.extraAttempts.lastUsedGame == game) {
    await ctx.answerCallbackQuery(
      text: "You have already used this power-up for the current game. 🫣",
      showAlert: true,
    );
    return;
  }

  await ctx.reply("Shoot your guess now. I'll take it as your free-hit. 😎");
  final c = await conv.waitForTextMessage(chatId: ctx.id);
  if (c == null) {
    await ctx.reply(
      "Oops, something went wrong I didn't get that. Don't worry, we haven't reduced the power-up count.",
    );
    return;
  }

  await _processGuess(ctx, user, c.msg!.text!, currentWord);
}

Future<void> _processGuess(
  Context ctx,
  WordleUser user,
  String guess,
  String currentWord,
) async {
  if (!user.onGame) {
    await ctx.reply(random(MessageStrings.notOnGameMessages));
    return;
  }

  guess = guess.trim().toLowerCase();
  if (guess.length != 5) {
    await ctx.reply(random(MessageStrings.mustBe5Letters));
    return;
  }

  if (!RegExp(r'[a-z]').hasMatch(guess)) {
    await ctx.reply(random(MessageStrings.mustBeLetters));
    return;
  }

  if (!await Dictionary.existingWord(guess)) {
    await ctx.reply(random(MessageStrings.notValidWord));
    return;
  }

  final result = getBoxes(currentWord, guess, user: user);
  await ctx.reply("Here's the result: 🫣.");
  await ctx.reply(result.join(" "));
  await ctx.reply("Time to continue guessing... 🤔");

  user.hints.extraAttempts.left--;
  user.hints.extraAttempts.lastUsedGame = gameNo();
  user.hints.usedHintsCount++;
}

Future<void> _updateUserHints(WordleUser user, String data) async {
  await user.save();
  WordleDB.incrementHintsUsage(data).ignore();
}

Future<void> _showHintOptions(Context ctx, WordleUser user) async {
  final useHintBoard = InlineKeyboard()
      .add("Letter Reveal (${user.hints.letterReveals.leftCount()})",
          useLetterPattern)
      .add("Extra Attempt (${user.hints.extraAttempts.leftCount()})",
          useAttemptPattern)
      .row()
      .add("🌟 Get more Hints", hintsGetPattern);

  bool showNewTag = DateTime.now().isBefore(PremiumHints.noLongerNew) &&
      user.hints.usedHintsCount < 3;

  await ctx.editMessageText(
    "${showNewTag ? "🆕 " : ""}You can use one of each hint once in a game.\n\n"
    "- <b>Extra Attempt</b>: Guess a word without including it on your 6 tries.\n"
    "- <b>Letter Reveal</b>: Reveal a letter from the actual word.\n\n"
    "Which hint are you choosing to use now?",
    replyMarkup: useHintBoard,
    parseMode: ParseMode.html,
  );
}
