part of '../xwordle.dart';

// Hints Patterns
const hintsGetPattern = "hints:get";
const useLetterPattern = "hints:use-letter";
const useAttemptPattern = "hints:use-attmpt";
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

Handler hintsGetHandler({bool shouldEdit = false}) {
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
    if (shouldEdit) {
      await ctx.editMessageCaption(
        caption: pricingMessage,
        parseMode: ParseMode.html,
        replyMarkup: board,
      );
    } else {
      await ctx.replyWithPhoto(
        InputFile.fromUrl(pic),
        caption: pricingMessage,
        parseMode: ParseMode.html,
        replyMarkup: board,
      );
    }
  };
}

Handler hintsIndividualHandler() {
  final text = """
<b>Individual Hints Plans:</b>

<b>Letter Reveal</b>:
  • 1 Letter Reveal: ⭐️ 35 
  • 3 Letter Reveals: ⭐️ 105 
  • 5 Letter Reveals: ⭐️ 175  <i>(32% off)</i> 🔥 

<b>Extra Attempt</b>:
  • 1 Extra Attempt: ⭐️ 75 
  • 3 Extra Attempts: ⭐️ 225 
  • 5 Extra Attempts: ⭐️ 299  <i>(21% off)</i> 🔥 
""";

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
    await ctx.editMessageCaption(
      caption: text,
      replyMarkup: board,
      parseMode: ParseMode.html,
    );
  };
}

class Plan {
  final String title;
  final String description;
  final String payload;
  final int amount;
  final int extraAttemptCount;
  final int letterRevealCount;

  const Plan({
    required this.title,
    required this.amount,
    required this.payload,
    required this.description,
    this.extraAttemptCount = 0,
    this.letterRevealCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "payload": payload,
      "amount": amount,
      "extraAttemptCount": extraAttemptCount,
      "letterRevealCount": letterRevealCount,
    };
  }

  static const all = [
    Plan(
      title: "Letter Reveal x1",
      amount: 35,
      description:
          "You can use this power-up to reveal a letter from the actual word. You will receive 1 Letter Reveal power up for 35 ⭐️.\n\nPlease continue to purchase by tapping the button below.",
      payload: "$letterreveal:1",
      letterRevealCount: 1,
    ),
    Plan(
      title: "Letter Reveal x3",
      amount: 105,
      description:
          "You can use this power-up to reveal a letter from the actual word. You will receive 3 Letter Reveal power up for 105 ⭐️.\n\nPlease continue to purchase by tapping the button below.",
      payload: "$letterreveal:3",
      letterRevealCount: 3,
    ),
    Plan(
      title: "Letter Reveal x5",
      amount: 175,
      description:
          "You can use this power-up to reveal a letter from the actual word. You will receive 5 Letter Reveal power up for 175 ⭐️.\n\nPlease continue to purchase by tapping the button below.",
      payload: "$letterreveal:5",
      letterRevealCount: 5,
    ),
    Plan(
      title: "Extra Attempt x1",
      amount: 75,
      description:
          "You can use this power-up to guess the word without including it on your 6 tries. You will receive 1 Extra Attempt power up for 75 ⭐️.\n\nPlease continue to purchase by tapping the button below.",
      payload: "$extraattempt:1",
      extraAttemptCount: 1,
    ),
    Plan(
      title: "Extra Attempt x3",
      amount: 225,
      description:
          "You can use this power-up to guess the word without including it on your 6 tries. You will receive 3 Extra Attempt power up for 225 ⭐️.\n\nPlease continue to purchase by tapping the button below.",
      payload: "$extraattempt:3",
      extraAttemptCount: 3,
    ),
    Plan(
      title: "Extra Attempt x5",
      amount: 299,
      description:
          "You can use this power-up to guess the word without including it on your 6 tries. You will receive 5 Extra Attempt power up for 299 ⭐️.\n\nPlease continue to purchase by tapping the button below.",
      payload: "$extraattempt:5",
      extraAttemptCount: 5,
    ),
    Plan(
      title: "Extra Attempt x5",
      amount: 299,
      description:
          "You can use this power-up to guess the word without including it on your 6 tries. You will receive 5 Extra Attempt power up for 299 ⭐️.\n\nPlease continue to purchase by tapping the button below.",
      payload: "$extraattempt:5",
      extraAttemptCount: 5,
    ),
    Plan(
      title: "Wordle Kickstart Bundle",
      amount: 149,
      payload: buykickstart,
      description:
          "This pack includes 3 Letter Reveals and 1 Extra Attempt power-ups. Get a head start with a mix of hints! Please continue to purchase by tapping the button below.",
      letterRevealCount: 3,
      extraAttemptCount: 1,
    ),
    Plan(
      title: "Wordle Advantage Pack",
      amount: 299,
      payload: buyadvantage,
      description:
          "This pack includes 7 Letter Reveals and 3 Extra Attempt power-ups. Perfect for more chances and reveals to boost your game!! Please continue to purchase by tapping the button below.",
      letterRevealCount: 7,
      extraAttemptCount: 3,
    ),
    Plan(
      title: "Wordle Domination Kit",
      amount: 699,
      payload: buydomination,
      description:
          "This pack includes 15 Letter Reveals and 7 Extra Attempt power-ups. Master the game with plenty of hints!! Please continue to purchase by tapping the button below.",
      letterRevealCount: 15,
      extraAttemptCount: 7,
    ),
  ];
}

Handler buyHandler(String pattern) {
  return (ctx) async {
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
    final r = ctx.msg?.successfulPayment;
    final user = await WordleUser.init(ctx.id.id);

    if (r != null) {
      db.doc("players/${ctx.id.id}/payments/${r.telegramPaymentChargeId}").set({
        "successful_payment": r.toJson(),
        "plan": plan.toMap(),
        "date": DateTime.now().unixTime,
        "user": user.id,
      }).ignore();
    }

    user.hints.addPlan(plan);
    await user.save();

    String text =
        "You have successfully activated <b>${plan.title}</b> 🎉.\n\n";
    final hintbalance = """
Here is your current hint balance:
- Extra Attempts: ${user.hints.extraAttempts.left}
- Letter Reveals: ${user.hints.letterReveals.left}

Start a new game and use the /hint command to access helpful power-ups. ⚡️
""";
    text += hintbalance;
    await ctx.reply(
      text,
      parseMode: ParseMode.html,
      messageEffectId: "5046509860389126442",
    );
  };
}
