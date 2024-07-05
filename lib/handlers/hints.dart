part of '../xwordle.dart';

// Hints Patterns
const hintsGetPattern = "hints:get";
const useLetterPattern = "hints:use-letter";
const useAttemptPattern = "hints:use-attmpt";
const hintsIndividual = "hints:individual";
const buykickstart = "buy:kickstart";
const buyadvantage = "buy:advantage";
const buydomination = "buy:domination";
const _letterreveal = "letterreveal";
const _extraattempt = "extraattempt";
final letterRevealPattern = RegExp(r"letterreveal:(.*)");
final extraattemptPattern = RegExp(r"extraattempt:(.*)");

Handler hintsHandler() {
  return (ctx) async {
    bool showNewTag = DateTime.now().isBefore(PremiumHints.noLongerNew);
    final getMoreBoard =
        InlineKeyboard().add("🌟 Get more Hints", hintsGetPattern);

    final user = await WordleUser.init(ctx.id.id);
    showNewTag = showNewTag && user.hints.usedHintsCount < 3;

    if (!user.onGame) {
      await ctx.reply(
        (showNewTag ? "🆕 " : "") + getHintInfoMessage(user.hints),
        replyMarkup: getMoreBoard,
      );
      return;
    }

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
      "${showNewTag ? "🆕 " : ""}You can use one of each hints once in a game.\n- Extra Attempt: Guess a word without including it on your 6 tries.\n- Letter Reveal: Reveal a letter from the actual word.\n\n"
      "Which hint are you choosing to use now?",
      replyMarkup: useHintBoard,
    );
  };
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

Handler hintsGetHandler() {
  const pic = "https://xwordle.web.app/assets/hints.png";
  const pricingMessage = """
✨ <b>Wordle Hint Pricing & Packs</b> ✨

<b>Individual Hints:</b>
- <b>Letter Reveal</b>: 35 ⭐️ stars 
- <b>Extra Attempt</b>: 75 ⭐️ stars 

<b>Combo Packs:</b>
- 🌟 <b>Wordle Kickstart Bundle</b>: 149 stars 
  • 3 Letter Reveals
  • 1 Extra Attempt
  Get a head start with a mix of hints!

- 🔥 <b>Wordle Advantage Pack</b>: 299 stars 
  • 7 Letter Reveals
  • 3 Extra Attempts
  More chances and reveals to boost your game!

- 🌟 <b>Wordle Domination Kit</b>: 699 stars 
  • 15 Letter Reveals
  • 7 Extra Attempts
  Master the game with plenty of hints!

Purchase your hints and packs to enhance your Wordle experience!
""";
  final board = InlineKeyboard()
      .add("Get Individual Hints 🌟", hintsIndividual)
      .row()
      .add("⭐️ Get Wordle Kickstart Bundle", buykickstart)
      .row()
      .add("🔥 Get Wordle Advantage Pack", buyadvantage)
      .row()
      .add("✨ Get Wordle Domination Kit", buydomination);
  return (ctx) async {
    await ctx.replyWithPhoto(
      InputFile.fromUrl(pic),
      caption: pricingMessage,
      parseMode: ParseMode.html,
      replyMarkup: board,
    );
  };
}

Handler hintsIndividualHandler() {
  final text = """
<b>Individual Hints Plans:</b>

<b>Letter Reveal</b>:
  • 1 Letter Reveal: 35 stars
  • 3 Letter Reveals: 105 stars
  • 5 Letter Reveals: 175 stars (32% off) 🔥 

<b>Extra Attempt</b>:
  • 1 Extra Attempt: 75 stars
  • 3 Extra Attempts: 225 stars
  • 5 Extra Attempts: 299 stars (21% off) 🔥 
""";

  final board = InlineKeyboard()
      .add("Letter Reveal - ⭐️ 35", "$_letterreveal:1")
      .row()
      .add("x1", "$_letterreveal:1")
      .add("x3", "$_letterreveal:3")
      .add("x5", "$_letterreveal:5")
      .row()
      .add("Extra Attempt - ⭐️ 75", "$_extraattempt:1")
      .row()
      .add("x1", "$_extraattempt:1")
      .add("x3", "$_extraattempt:3")
      .add("x5", "$_extraattempt:5");
  return (ctx) async {
    await ctx.editMessageCaption(
      caption: text,
      replyMarkup: board,
      parseMode: ParseMode.html,
    );
  };
}
