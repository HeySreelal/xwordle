part of '../xwordle.dart';

/// Pattern used to match donation method
final donatePattern = RegExp(r"donate:(.*)");

/// Pattern used to match star count callback query
final starsCountPattern = RegExp(r"stars:(.*)");

Handler donateHandler() {
  const kdonate = "donate";

  final board =
      InlineKeyboard().add("Continue with Telegram Stars ⭐️", "$kdonate:stars");
  return (ctx) async {
    ctx.reply(
      "🙏 Thank you so much for considering a donation to support Wordle Bot! Your generosity helps keep this project running."
      "\n\nPlease continue to selecting number of stars to donate by pressing the button below. Your support means a lot! 💖",
      replyMarkup: board,
    );
  };
}

Handler donateCallbackHandler() {
  final countBoard = InlineKeyboard();
  for (var op in DonateOption.options) {
    countBoard.add("$op", "stars:${op.count}");
    countBoard.row();
  }

  return (ctx) async {
    ctx.answerCallbackQuery().ignore();
    final data = ctx.callbackQuery!.data!;
    final method = DonationMethod.fromString(data.split(":")[1]);
    final text = switch (method) {
      DonationMethod.stars => MessageStrings.starDonationPrompt,
    };

    final b = method == DonationMethod.stars ? countBoard : InlineKeyboard();

    await ctx.editMessageText(
      text,
      replyMarkup: b,
      parseMode: ParseMode.html,
    );
  };
}

Handler starsCountSelectionHandler() {
  return (ctx) async {
    ctx.answerCallbackQuery().ignore();
    int count;
    try {
      final d = ctx.callbackQuery!.data!.split(":")[1];
      count = int.tryParse(d) ?? 99;
    } catch (_) {
      count = 99;
    }
    final op = DonateOption.find(count);
    await ctx.editMessageText(
      "Thanks for choosing $op. Every star counts, and yours makes a difference!",
      replyMarkup: InlineKeyboard(),
    );
    await ctx.sendInvoice(
      title: "Wordle Bot Donation",
      description: MessageStrings.donationDescription,
      payload: "donation",
      currency: "XTR",
      prices: [
        LabeledPrice(label: "Send Stars", amount: count),
      ],
    );
  };
}

// Define a function to check if the user should be nudged to donate
bool shouldNudge() {
  // Adjust the probability as desired, for example, 30% chance
  return Random().nextInt(100) < 30; // 30% chance
}

void nudgeDonation(
  Context ctx, {
  bool straight = false,
}) async {
  final nudges = [
    "🌟 Enjoying Wordle Bot? <tg-spoiler>Consider supporting us with a donation! Use /donate to learn more.</tg-spoiler>",
    "Loving the Wordle Bot experience? <tg-spoiler>Fuel the fun with a donation! Use /donate to show your love! ❤️</tg-spoiler>",
    "<tg-spoiler>Can't get enough of Wordle Bot? Help us keep it going strong with a donation! Use /donate to become a hero!</tg-spoiler>",
    "<tg-spoiler>Feeling lucky in Wordle Bot? Share the luck with a donation! Use /donate to keep the good times rolling! </tg-spoiler>",
  ];
  // Optionally nudge the user to donate randomly
  if (!straight ? shouldNudge() : true) {
    try {
      await ctx.reply(
        random(nudges),
        parseMode: ParseMode.html,
      );
    } catch (e, stack) {
      errorHandler(BotError(e, stack)).ignore();
    }
  }
}

Handler successPaymentHandler() {
  return (ctx) async {
    final r = ctx.msg!.successfulPayment!;
    db.collection("payments").add({"type": "donation", ...r.toJson()}).ignore();

    final successString =
        "✅ Payment #<code>${r.telegramPaymentChargeId}</code> success!\n\n";
    if (r.invoicePayload == "donation") {
      await ctx.reply(
        "${successString}Thank you so much for your generous contribution! Your donation helps power our bot development. We have successfully received ${r.totalAmount} in Telegram Stars ⭐️.",
        parseMode: ParseMode.html,
      );
      return;
    }

    const hintPayloads = [
      "$letterreveal:1",
      "$letterreveal:3",
      "$letterreveal:5",
      "$extraattempt:1",
      "$extraattempt:3",
      "$extraattempt:5",
      "$extraattempt:5",
      buykickstart,
      buyadvantage,
      buydomination,
    ];
    if (hintPayloads.contains(r.invoicePayload)) {
      await handleSuccessPaymentForHints(r.invoicePayload)(ctx);
    }
  };
}
